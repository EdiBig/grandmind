const cors = require("cors")({origin: true});
const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");

const CLAUDE_API_KEY = defineSecret("CLAUDE_API_KEY");
const CLAUDE_API_URL = "https://api.anthropic.com/v1/messages";
const CLAUDE_API_VERSION = "2023-06-01";

exports.claudeProxy = onRequest(
  {secrets: [CLAUDE_API_KEY], region: "us-central1", invoker: "public"},
  (req, res) => {
    cors(req, res, async () => {
      if (req.method !== "POST") {
        res.status(405).json({error: {message: "Method not allowed"}});
        return;
      }

      const body = req.body || {};
      const messages = body.messages;

      if (!Array.isArray(messages) || messages.length === 0) {
        res.status(400).json({error: {message: "messages is required"}});
        return;
      }

      const payload = {
        model: body.model || "claude-3-haiku-20240307",
        max_tokens: body.max_tokens || 1024,
        temperature:
          typeof body.temperature === "number" ? body.temperature : 0.7,
        messages: messages,
      };

      if (typeof body.system === "string" && body.system.trim().length > 0) {
        payload.system = body.system;
      }

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
          res.status(response.status).json(data);
          return;
        }

        res.status(200).json(data);
      } catch (error) {
        res.status(500).json({
          error: {message: "Claude proxy failed", detail: String(error)},
        });
      }
    });
  },
);
