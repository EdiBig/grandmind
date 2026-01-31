const cors = require("cors")({origin: true});
const admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");
const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onDocumentWritten} = require("firebase-functions/v2/firestore");
const {defineSecret} = require("firebase-functions/params");

admin.initializeApp();

const CLAUDE_API_KEY = defineSecret("CLAUDE_API_KEY");
const CLAUDE_API_URL = "https://api.anthropic.com/v1/messages";
const CLAUDE_API_VERSION = "2023-06-01";
const WGER_API_KEY = defineSecret("WGER_API_KEY");
const WGER_SYNC_TOKEN = defineSecret("WGER_SYNC_TOKEN");
const ALGOLIA_APP_ID = defineSecret("ALGOLIA_APP_ID");
const ALGOLIA_ADMIN_KEY = defineSecret("ALGOLIA_ADMIN_KEY");
const ALGOLIA_INDEX = defineSecret("ALGOLIA_INDEX");
const HABIT_BACKFILL_TOKEN = defineSecret("HABIT_BACKFILL_TOKEN");

const WGER_BASE_URL = "https://wger.de/api/v2";
const WGER_LANGUAGE_ID_EN = 2;
const WORKOUTS_COLLECTION = "workouts";
const WGER_SOURCE = "wger";

// Rate limiting: track requests per UID (in-memory, resets on cold start)
// For production, consider using Redis or Firestore for persistent rate limiting
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 20; // 20 requests per minute per user

// Allowed models whitelist
const ALLOWED_MODELS = [
  "claude-3-haiku-20240307",
  "claude-3-sonnet-20240229",
  "claude-3-5-sonnet-20241022",
];

// Max payload constraints
const MAX_SYSTEM_LENGTH = 4000;
const MAX_MESSAGE_LENGTH = 8000;
const MAX_MESSAGES_COUNT = 50;
const MAX_TOKENS_LIMIT = 4096;

/**
 * Verify Firebase ID token from Authorization header
 * @param {string} authHeader - Authorization header value
 * @returns {Promise<{uid: string, email: string}|null>} Decoded token or null
 */
async function verifyFirebaseToken(authHeader) {
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }
  const idToken = authHeader.substring(7);
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return {uid: decodedToken.uid, email: decodedToken.email || null};
  } catch (error) {
    console.warn("Token verification failed:", error.message);
    return null;
  }
}

/**
 * Check rate limit for a user
 * @param {string} uid - User ID
 * @returns {{allowed: boolean, remaining: number, resetIn: number}}
 */
function checkRateLimit(uid) {
  const now = Date.now();
  const userLimit = rateLimitMap.get(uid);

  if (!userLimit || now - userLimit.windowStart > RATE_LIMIT_WINDOW_MS) {
    // New window
    rateLimitMap.set(uid, {windowStart: now, count: 1});
    return {allowed: true, remaining: RATE_LIMIT_MAX_REQUESTS - 1, resetIn: RATE_LIMIT_WINDOW_MS};
  }

  if (userLimit.count >= RATE_LIMIT_MAX_REQUESTS) {
    const resetIn = RATE_LIMIT_WINDOW_MS - (now - userLimit.windowStart);
    return {allowed: false, remaining: 0, resetIn};
  }

  userLimit.count += 1;
  return {
    allowed: true,
    remaining: RATE_LIMIT_MAX_REQUESTS - userLimit.count,
    resetIn: RATE_LIMIT_WINDOW_MS - (now - userLimit.windowStart),
  };
}

/**
 * Validate request payload
 * @param {object} body - Request body
 * @returns {{valid: boolean, error?: string}}
 */
function validatePayload(body) {
  const {messages, model, max_tokens: maxTokens, system} = body;

  // Validate messages
  if (!Array.isArray(messages) || messages.length === 0) {
    return {valid: false, error: "messages is required and must be non-empty array"};
  }
  if (messages.length > MAX_MESSAGES_COUNT) {
    return {valid: false, error: `Too many messages (max ${MAX_MESSAGES_COUNT})`};
  }
  for (const msg of messages) {
    if (typeof msg.content === "string" && msg.content.length > MAX_MESSAGE_LENGTH) {
      return {valid: false, error: `Message too long (max ${MAX_MESSAGE_LENGTH} chars)`};
    }
  }

  // Validate model
  if (model && !ALLOWED_MODELS.includes(model)) {
    return {valid: false, error: `Model not allowed. Use: ${ALLOWED_MODELS.join(", ")}`};
  }

  // Validate max_tokens
  if (maxTokens && (typeof maxTokens !== "number" || maxTokens > MAX_TOKENS_LIMIT)) {
    return {valid: false, error: `max_tokens must be <= ${MAX_TOKENS_LIMIT}`};
  }

  // Validate system prompt
  if (system && typeof system === "string" && system.length > MAX_SYSTEM_LENGTH) {
    return {valid: false, error: `System prompt too long (max ${MAX_SYSTEM_LENGTH} chars)`};
  }

  return {valid: true};
}

exports.claudeProxy = onRequest(
  {secrets: [CLAUDE_API_KEY], region: "us-central1", invoker: "public"},
  (req, res) => {
    cors(req, res, async () => {
      // 1. Method check
      if (req.method !== "POST") {
        res.status(405).json({error: {message: "Method not allowed"}});
        return;
      }

      // 2. Verify Firebase ID token (REQUIRED)
      const user = await verifyFirebaseToken(req.get("Authorization"));
      if (!user) {
        res.status(401).json({error: {message: "Unauthorized: Invalid or missing Firebase ID token"}});
        return;
      }

      // 3. Rate limiting per UID
      const rateLimit = checkRateLimit(user.uid);
      res.set("X-RateLimit-Remaining", String(rateLimit.remaining));
      res.set("X-RateLimit-Reset", String(Math.ceil(rateLimit.resetIn / 1000)));

      if (!rateLimit.allowed) {
        res.status(429).json({
          error: {
            message: "Rate limit exceeded",
            retryAfter: Math.ceil(rateLimit.resetIn / 1000),
          },
        });
        return;
      }

      // 4. Validate payload
      const body = req.body || {};
      const validation = validatePayload(body);
      if (!validation.valid) {
        res.status(400).json({error: {message: validation.error}});
        return;
      }

      // 5. Build sanitized payload
      const payload = {
        model: body.model || "claude-3-haiku-20240307",
        max_tokens: Math.min(body.max_tokens || 1024, MAX_TOKENS_LIMIT),
        temperature:
          typeof body.temperature === "number" ?
            Math.max(0, Math.min(1, body.temperature)) : 0.7,
        messages: body.messages,
      };

      if (typeof body.system === "string" && body.system.trim().length > 0) {
        payload.system = body.system.substring(0, MAX_SYSTEM_LENGTH);
      }

      // 6. Call Claude API
      try {
        const response = await fetch(CLAUDE_API_URL, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-api-key": CLAUDE_API_KEY.value(),
            "anthropic-version": CLAUDE_API_VERSION,
          },
          body: JSON.stringify(payload),
        });

        const data = await response.json();
        if (!response.ok) {
          // Don't expose internal API errors in detail
          console.error(`Claude API error for user ${user.uid}:`, data);
          res.status(response.status >= 500 ? 502 : response.status).json({
            error: {message: data.error?.message || "AI service error"},
          });
          return;
        }

        res.status(200).json(data);
      } catch (error) {
        console.error(`Claude proxy error for user ${user.uid}:`, error);
        res.status(500).json({
          error: {message: "AI service temporarily unavailable"},
        });
      }
    });
  },
);

exports.syncWgerWorkouts = onSchedule(
  {
    schedule: "every 24 hours",
    region: "us-central1",
    secrets: [WGER_API_KEY],
  },
  async () => {
    await _syncWgerWorkouts();
  },
);

exports.syncWgerWorkoutsNow = onRequest(
  {
    region: "us-central1",
    secrets: [WGER_API_KEY, WGER_SYNC_TOKEN],
    invoker: "public",
  },
  async (req, res) => {
    const token =
      req.get("x-sync-token") || req.query.token || req.body?.token;
    if (token !== WGER_SYNC_TOKEN.value()) {
      res.status(403).json({error: {message: "Unauthorized"}});
      return;
    }
    try {
      await _syncWgerWorkouts();
      res.status(200).json({status: "ok"});
    } catch (error) {
      res.status(500).json({error: {message: String(error)}});
    }
  },
);

exports.indexWorkoutSearch = onDocumentWritten(
  {document: `${WORKOUTS_COLLECTION}/{workoutId}`, region: "us-central1"},
  async (event) => {
    const after = event.data?.after?.data();
    if (!after) return;
    const keywords = _buildSearchKeywordsFromWorkout(after);
    const current = Array.isArray(after.searchKeywords) ? after.searchKeywords : [];
    if (_arraysEqual(keywords, current)) return;
    await event.data.after.ref.update({
      searchKeywords: keywords,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  },
);

exports.indexWorkoutAlgolia = onDocumentWritten(
  {
    document: `${WORKOUTS_COLLECTION}/{workoutId}`,
    region: "us-central1",
    secrets: [ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY, ALGOLIA_INDEX],
  },
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    const client = algoliasearch(
      ALGOLIA_APP_ID.value(),
      ALGOLIA_ADMIN_KEY.value(),
    );
    const index = client.initIndex(ALGOLIA_INDEX.value());
    const objectID = event.params.workoutId;

    if (!after) {
      if (before) {
        await index.deleteObject(objectID);
      }
      return;
    }

    const record = _buildAlgoliaRecord(after, objectID);
    await index.saveObject(record);
  },
);

exports.configureAlgoliaIndex = onRequest(
  {
    region: "us-central1",
    secrets: [ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY, ALGOLIA_INDEX, WGER_SYNC_TOKEN],
    invoker: "public",
  },
  async (req, res) => {
    const token =
      req.get("x-sync-token") || req.query.token || req.body?.token;
    if (token !== WGER_SYNC_TOKEN.value()) {
      res.status(403).json({error: {message: "Unauthorized"}});
      return;
    }
    try {
      const client = algoliasearch(
        ALGOLIA_APP_ID.value(),
        ALGOLIA_ADMIN_KEY.value(),
      );
      const index = client.initIndex(ALGOLIA_INDEX.value());
      await index.setSettings({
        searchableAttributes: [
          "name",
          "description",
          "tags",
          "muscleGroups",
          "equipment",
          "category",
        ],
        attributesForFaceting: [
          "filterOnly(category)",
          "filterOnly(difficulty)",
          "filterOnly(source)",
          "filterOnly(isTemplate)",
          "filterOnly(createdBy)",
          "filterOnly(equipment)",
          "filterOnly(tags)",
        ],
      });
      res.status(200).json({status: "ok"});
    } catch (error) {
      res.status(500).json({error: {message: String(error)}});
    }
  },
);

exports.backfillHabitLogUserIds = onRequest(
  {
    region: "us-central1",
    secrets: [HABIT_BACKFILL_TOKEN],
    invoker: "private",
  },
  async (req, res) => {
    const token =
      req.get("x-sync-token") || req.query.token || req.body?.token;
    if (token !== HABIT_BACKFILL_TOKEN.value()) {
      res.status(403).json({error: {message: "Unauthorized"}});
      return;
    }

    const db = admin.firestore();
    const pageSize = Math.min(Number(req.query.pageSize) || 200, 500);
    const maxDocs = Math.min(Number(req.query.maxDocs) || 5000, 50000);
    let processed = 0;
    let updated = 0;
    let skipped = 0;
    let lastDoc = null;
    const habitCache = new Map();

    while (processed < maxDocs) {
      let query = db
          .collection("habit_logs")
          .where("userId", "==", null)
          .orderBy(admin.firestore.FieldPath.documentId())
          .limit(pageSize);

      if (lastDoc) {
        query = query.startAfter(lastDoc);
      }

      const snapshot = await query.get();
      if (snapshot.empty) break;

      let batch = db.batch();
      let batchCount = 0;

      for (const doc of snapshot.docs) {
        processed += 1;
        lastDoc = doc;

        const data = doc.data() || {};
        const habitId = data.habitId;
        if (!habitId) {
          skipped += 1;
          continue;
        }

        let habitUserId = habitCache.get(habitId);
        if (!habitUserId) {
          const habitDoc = await db.collection("habits").doc(habitId).get();
          habitUserId = habitDoc.exists ? habitDoc.data()?.userId : null;
          habitCache.set(habitId, habitUserId || null);
        }

        if (!habitUserId) {
          skipped += 1;
          continue;
        }

        batch.update(doc.ref, {
          userId: habitUserId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        updated += 1;
        batchCount += 1;

        if (batchCount >= 400) {
          await batch.commit();
          batch = db.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      if (snapshot.size < pageSize) {
        break;
      }
    }

    res.status(200).json({
      status: "ok",
      processed,
      updated,
      skipped,
    });
  },
);

async function _syncWgerWorkouts() {
  const db = admin.firestore();
  const syncStatusRef = db.collection("sync_status").doc("wger");
  const now = admin.firestore.FieldValue.serverTimestamp();

  // Mark sync as in progress
  await syncStatusRef.set({
    isSyncing: true,
    lastSyncStartedAt: now,
  }, {merge: true});

  let nextUrl = `${WGER_BASE_URL}/exerciseinfo/?limit=100&language=${WGER_LANGUAGE_ID_EN}`;
  let batch = db.batch();
  let batchCount = 0;
  let totalExercises = 0;
  let retryCount = 0;
  const maxRetries = 3;

  try {
    while (nextUrl) {
      let response;
      let data;

      // Retry logic for transient errors
      for (let attempt = 0; attempt <= maxRetries; attempt++) {
        try {
          response = await fetch(nextUrl, {
            headers: _buildWgerHeaders(),
          });

          if (response.ok) {
            data = await response.json();
            break;
          }

          // Rate limited - wait and retry
          if (response.status === 429) {
            const retryAfter = parseInt(response.headers.get("retry-after") || "5", 10);
            await _sleep(retryAfter * 1000);
            retryCount++;
            continue;
          }

          // Server error - retry with backoff
          if (response.status >= 500 && attempt < maxRetries) {
            await _sleep(Math.pow(2, attempt) * 1000);
            retryCount++;
            continue;
          }

          throw new Error(`wger API error: ${response.status}`);
        } catch (fetchError) {
          if (attempt === maxRetries) {
            throw fetchError;
          }
          await _sleep(Math.pow(2, attempt) * 1000);
          retryCount++;
        }
      }

      const results = Array.isArray(data.results) ? data.results : [];

      for (const exercise of results) {
        const workout = _mapWgerExerciseToWorkout(exercise);
        const docId = `wger_${exercise.id}`;
        const docRef = db.collection(WORKOUTS_COLLECTION).doc(docId);
        batch.set(
            docRef,
            {
              ...workout,
              updatedAt: now,
              createdAt: workout.createdAt || now,
            },
            {merge: true},
        );
        batchCount += 1;
        totalExercises += 1;

        if (batchCount >= 400) {
          await batch.commit();
          batch = db.batch();
          batchCount = 0;
        }
      }

      nextUrl = data.next;
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    // Update sync status on success
    await syncStatusRef.set({
      isSyncing: false,
      status: "success",
      lastSyncAt: now,
      exerciseCount: totalExercises,
      retryCount: retryCount,
      errorMessage: null,
    });

    console.log(`wger sync completed: ${totalExercises} exercises, ${retryCount} retries`);
  } catch (error) {
    // Update sync status on failure
    await syncStatusRef.set({
      isSyncing: false,
      status: "error",
      lastSyncAt: now,
      errorMessage: String(error),
      exerciseCount: totalExercises,
    }, {merge: true});

    throw error;
  }
}

function _sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function _buildWgerHeaders() {
  const headers = {"Content-Type": "application/json"};
  const apiKey = WGER_API_KEY.value();
  if (apiKey && apiKey.trim().length > 0) {
    headers.Authorization = `Token ${apiKey}`;
  }
  return headers;
}

function _mapWgerExerciseToWorkout(exercise) {
  const translation = _pickTranslation(exercise.translations || []);
  const name = translation?.name || "Workout";
  const description = _stripHtml(translation?.description || "");
  const equipment = (exercise.equipment || [])
      .map((item) => item.name)
      .filter(Boolean);
  const muscles = _collectMuscles(exercise);
  const category = _mapCategory(exercise.category?.name);
  const tags = [
    ...equipment,
    ...muscles,
    category,
  ].filter(Boolean);
  const imagePath = (exercise.images || [])
      .map((img) => img.image)
      .filter(Boolean)[0] || null;
  const imageUrl = imagePath ? _absoluteWgerUrl(imagePath) : null;
  const videoPath = (exercise.videos || [])
      .map((vid) => vid.video)
      .filter(Boolean)[0] || null;
  const videoUrl = videoPath ? _absoluteWgerUrl(videoPath) : null;
  const attribution = _buildAttribution(exercise, translation);

  return {
    id: `wger_${exercise.id}`,
    externalId: exercise.id,
    source: WGER_SOURCE,
    createdBy: null, // Explicitly null so Flutter query matches
    name,
    description: description || "Exercise from wger.",
    difficulty: "beginner",
    estimatedDuration: 20,
    category,
    exercises: [
      {
        id: String(exercise.id),
        name,
        description: description || "Exercise from wger.",
        type: "reps",
        muscleGroups: muscles,
        equipment: equipment.join(", ") || null,
        imageUrl,
        videoUrl,
      },
    ],
    attribution,
    equipment: equipment.join(", ") || null,
    tags,
    searchKeywords: _buildSearchKeywords(
      [name, description, category, ...equipment, ...muscles],
    ),
    isTemplate: true,
  };
}

function _pickTranslation(translations) {
  if (!Array.isArray(translations) || translations.length === 0) return null;

  // Try to find English translation
  // Handle both numeric ID (2) and potential string formats
  const preferred = translations.find((item) => {
    const lang = item.language;
    // Numeric comparison (most common for wger API)
    if (lang === WGER_LANGUAGE_ID_EN) return true;
    // String comparison fallback
    if (typeof lang === "string") {
      const lower = lang.toLowerCase();
      return lower === "en" || lower === "english" || lower === "2";
    }
    return false;
  });

  return preferred || translations[0] || null;
}

function _collectMuscles(exercise) {
  const primary = Array.isArray(exercise.muscles) ? exercise.muscles : [];
  const secondary = Array.isArray(exercise.muscles_secondary) ?
    exercise.muscles_secondary : [];
  return [...primary, ...secondary]
      .map((item) => item.name_en || item.name)
      .filter(Boolean);
}

function _mapCategory(name) {
  if (!name) return "strength";
  const normalized = name.toLowerCase();
  if (normalized.includes("cardio") || normalized.includes("run")) {
    return "cardio";
  }
  if (normalized.includes("stretch") || normalized.includes("flex")) {
    return "flexibility";
  }
  if (normalized.includes("yoga")) {
    return "yoga";
  }
  return "strength";
}

function _stripHtml(input) {
  return String(input)
      .replace(/<[^>]*>/g, " ")
      .replace(/\s+/g, " ")
      .trim();
}

function _buildAttribution(exercise, translation) {
  const license = exercise.license || {};
  const sourceUrl = `https://wger.de/en/exercise/${exercise.id}`;
  return {
    source: "wger",
    sourceUrl,
    licenseName: license.full_name || license.short_name || null,
    licenseUrl: license.url || null,
    author: translation?.license_author || exercise.license_author || null,
    authorUrl: translation?.license_author_url || null,
    licenseTitle: translation?.license_title || null,
    licenseObjectUrl: translation?.license_object_url || null,
    derivativeSourceUrl: translation?.license_derivative_source_url || null,
  };
}

function _absoluteWgerUrl(path) {
  if (!path) return null;
  if (path.startsWith("http://") || path.startsWith("https://")) {
    return path;
  }
  return `https://wger.de${path}`;
}

function _buildSearchKeywordsFromWorkout(workout) {
  const parts = [
    workout.name,
    workout.description,
    workout.category,
    workout.equipment,
  ];
  if (Array.isArray(workout.tags)) {
    parts.push(...workout.tags);
  }
  if (Array.isArray(workout.exercises)) {
    for (const exercise of workout.exercises) {
      parts.push(exercise.name);
      if (Array.isArray(exercise.muscleGroups)) {
        parts.push(...exercise.muscleGroups);
      }
      if (exercise.equipment) {
        parts.push(exercise.equipment);
      }
    }
  }
  return _buildSearchKeywords(parts);
}

function _buildAlgoliaRecord(workout, objectID) {
  const muscles = [];
  if (Array.isArray(workout.exercises)) {
    for (const exercise of workout.exercises) {
      if (Array.isArray(exercise.muscleGroups)) {
        muscles.push(...exercise.muscleGroups);
      }
    }
  }

  return {
    objectID,
    name: workout.name,
    description: workout.description,
    category: workout.category,
    difficulty: workout.difficulty,
    estimatedDuration: workout.estimatedDuration,
    equipment: workout.equipment || null,
    tags: Array.isArray(workout.tags) ? workout.tags : [],
    muscleGroups: muscles,
    source: workout.source || null,
    isTemplate: Boolean(workout.isTemplate),
    createdBy: workout.createdBy || null,
    imageUrl: workout.exercises?.[0]?.imageUrl || null,
    videoUrl: workout.exercises?.[0]?.videoUrl || null,
    createdAt: workout.createdAt || null,
  };
}

function _buildSearchKeywords(parts) {
  const tokens = new Set();
  for (const part of parts) {
    if (!part) continue;
    const normalized = String(part).toLowerCase();
    const matches = normalized.match(/[a-z0-9]+/g) || [];
    for (const match of matches) {
      if (match.length >= 2) {
        tokens.add(match);
      }
    }
  }
  return Array.from(tokens).sort();
}

function _arraysEqual(a, b) {
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) {
    if (a[i] !== b[i]) return false;
  }
  return true;
}
