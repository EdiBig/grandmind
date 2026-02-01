/**
 * Migration Script: Populate memberIds array for existing circles
 *
 * This script reads all existing circles, fetches their members from the
 * subcollection, and updates each circle document with the memberIds array.
 *
 * Usage:
 *   1. Make sure you're logged in: firebase login
 *   2. Run: node migrate_circle_member_ids.js
 *
 * Options:
 *   --dry-run    Preview changes without writing to Firestore
 *   --verbose    Show detailed progress for each circle
 */

const admin = require('firebase-admin');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const DRY_RUN = args.includes('--dry-run');
const VERBOSE = args.includes('--verbose');

// Project ID
const PROJECT_ID = 'grandmind-kinesa';

// Initialize Firebase Admin using application default credentials
// This uses the credentials from `firebase login`
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

let initialized = false;

// Try service account key first
try {
  const serviceAccount = require(serviceAccountPath);
  if (serviceAccount.type === 'service_account') {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    initialized = true;
    console.log('Using service account credentials.\n');
  }
} catch (error) {
  // Service account not available, try application default credentials
}

// Fall back to application default credentials (from gcloud or firebase login)
if (!initialized) {
  try {
    admin.initializeApp({
      projectId: PROJECT_ID,
    });
    console.log('Using application default credentials.\n');
  } catch (error) {
    console.error('Error: Could not initialize Firebase Admin.');
    console.error('Please run: firebase login');
    process.exit(1);
  }
}

const db = admin.firestore();

async function migrateCircleMemberIds() {
  console.log('='.repeat(60));
  console.log('Circle memberIds Migration Script');
  console.log('='.repeat(60));

  if (DRY_RUN) {
    console.log('\n⚠️  DRY RUN MODE - No changes will be written to Firestore\n');
  }

  try {
    // Get all circles
    console.log('Fetching all circles...');
    const circlesSnapshot = await db.collection('circles').get();

    if (circlesSnapshot.empty) {
      console.log('No circles found in the database.');
      return;
    }

    console.log(`Found ${circlesSnapshot.size} circle(s) to process.\n`);

    let processed = 0;
    let updated = 0;
    let skipped = 0;
    let errors = 0;

    for (const circleDoc of circlesSnapshot.docs) {
      const circleId = circleDoc.id;
      const circleData = circleDoc.data();
      const circleName = circleData.name || 'Unnamed Circle';

      try {
        if (VERBOSE) {
          console.log(`Processing: ${circleName} (${circleId})`);
        }

        // Check if memberIds already exists and is populated
        const existingMemberIds = circleData.memberIds || [];

        // Get all members from the subcollection
        const membersSnapshot = await db
          .collection('circles')
          .doc(circleId)
          .collection('members')
          .get();

        const memberIds = membersSnapshot.docs.map(doc => {
          const data = doc.data();
          // The member doc ID is usually the userId, but also check the userId field
          return data.userId || doc.id;
        });

        // Remove duplicates
        const uniqueMemberIds = [...new Set(memberIds)];

        if (VERBOSE) {
          console.log(`  - Found ${uniqueMemberIds.length} member(s) in subcollection`);
          console.log(`  - Existing memberIds: ${existingMemberIds.length}`);
        }

        // Check if update is needed
        const existingSet = new Set(existingMemberIds);
        const newSet = new Set(uniqueMemberIds);
        const needsUpdate =
          existingMemberIds.length !== uniqueMemberIds.length ||
          ![...newSet].every(id => existingSet.has(id));

        if (!needsUpdate) {
          if (VERBOSE) {
            console.log(`  - ✓ Already up to date, skipping\n`);
          }
          skipped++;
          processed++;
          continue;
        }

        // Update the circle document
        if (!DRY_RUN) {
          await db.collection('circles').doc(circleId).update({
            memberIds: uniqueMemberIds,
          });
        }

        console.log(`✓ Updated "${circleName}": ${uniqueMemberIds.length} member(s)`);
        if (VERBOSE && uniqueMemberIds.length > 0) {
          console.log(`  Member IDs: ${uniqueMemberIds.join(', ')}\n`);
        }

        updated++;
        processed++;

      } catch (error) {
        console.error(`✗ Error processing "${circleName}" (${circleId}): ${error.message}`);
        errors++;
        processed++;
      }
    }

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('Migration Summary');
    console.log('='.repeat(60));
    console.log(`Total circles processed: ${processed}`);
    console.log(`Updated: ${updated}`);
    console.log(`Skipped (already up to date): ${skipped}`);
    console.log(`Errors: ${errors}`);

    if (DRY_RUN) {
      console.log('\n⚠️  This was a DRY RUN. Run without --dry-run to apply changes.');
    } else if (updated > 0) {
      console.log('\n✓ Migration completed successfully!');
    }

  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

// Run the migration
migrateCircleMemberIds()
  .then(() => {
    console.log('\nDone.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Unexpected error:', error);
    process.exit(1);
  });
