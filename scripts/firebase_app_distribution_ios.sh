#!/usr/bin/env bash
set -euo pipefail

APP_ID="${APP_ID:-1:891051622598:ios:60a2b9b0d18a7fd310d7c7}"
IPA_PATH="${IPA_PATH:-build/ios/ipa/*.ipa}"
GROUPS="${GROUPS:-kinesa-testers}"
PROJECT_ID="${PROJECT_ID:-grandmind-kinesa}"
RELEASE_NOTES="${RELEASE_NOTES:-New iOS build for testing}"

if ! command -v firebase >/dev/null 2>&1; then
  echo "Firebase CLI not found. Install: npm install -g firebase-tools" >&2
  exit 1
fi

firebase appdistribution:distribute $IPA_PATH \
  --app "$APP_ID" \
  --groups "$GROUPS" \
  --project "$PROJECT_ID" \
  --release-notes "$RELEASE_NOTES"
