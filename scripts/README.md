# Scripts

Migration and utility scripts for Grandmind/Kinesa.

## Setup

1. Install dependencies:
   ```bash
   cd scripts
   npm install
   ```

2. Download your Firebase service account key:
   - Go to [Firebase Console](https://console.firebase.google.com/project/grandmind-kinesa/settings/serviceaccounts/adminsdk)
   - Click **"Generate New Private Key"**
   - Save the file as `serviceAccountKey.json` in this `scripts` folder

   > **Important:** Never commit `serviceAccountKey.json` to version control!

## Available Scripts

### migrate_circle_member_ids.js

Populates the `memberIds` array field on existing Circle documents by reading from the `members` subcollection. This is needed after the Unity feature update that changed how user circles are queried.

**Dry run (preview changes):**
```bash
npm run migrate:circle-members:dry-run
```

**Apply changes:**
```bash
npm run migrate:circle-members
```

**Options:**
- `--dry-run` - Preview changes without writing to Firestore
- `--verbose` - Show detailed progress for each circle

**What it does:**
1. Fetches all documents from the `circles` collection
2. For each circle, reads all documents from its `members` subcollection
3. Extracts the `userId` from each member document
4. Updates the circle document with `memberIds: [userId1, userId2, ...]`

**Example output:**
```
============================================================
Circle memberIds Migration Script
============================================================
Fetching all circles...
Found 5 circle(s) to process.

✓ Updated "Running Buddies": 3 member(s)
✓ Updated "Morning Yoga": 2 member(s)
✓ Updated "Fitness Squad": 4 member(s)

============================================================
Migration Summary
============================================================
Total circles processed: 5
Updated: 3
Skipped (already up to date): 2
Errors: 0

✓ Migration completed successfully!
```
