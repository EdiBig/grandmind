# Nutrition Feature - Required Configuration Updates

## ⚠️ Manual Updates Required

These configuration files need manual updates (auto-save is interfering):

---

## 1. firestore.indexes.json

Add these indexes to the `"indexes"` array (before the closing `]`):

```json
    {
      "collectionGroup": "meals",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "mealDate",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "loggedAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "meals",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "mealDate",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "water_logs",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "date",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "water_logs",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "date",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "food_items",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "isVerified",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "category",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "food_items",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isCustom",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "nutrition_goals",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
```

---

## 2. firestore.rules

Add these rules BEFORE the final `// Deny all other access by default` section:

```javascript
    // Meals collection - users can only access their own meals
    match /meals/{mealId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }

    // Water logs collection - users can only access their own water logs
    match /water_logs/{logId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }

    // Nutrition goals collection - users can only access their own goals
    match /nutrition_goals/{goalId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }

    // Food items collection - read: all authenticated, write: only owner
    match /food_items/{foodId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }
```

---

## 3. Deploy Indexes to Firebase

After updating `firestore.indexes.json`, deploy to Firebase:

```bash
firebase deploy --only firestore:indexes
```

---

## 4. Deploy Security Rules to Firebase

After updating `firestore.rules`, deploy to Firebase:

```bash
firebase deploy --only firestore:rules
```

---

## ✅ Verification

After deployment, test:
1. Try logging a meal (should work)
2. Try reading another user's meal (should fail)
3. Try incrementing water (should work)
4. Try searching food items (should work for all authenticated users)
5. Try creating custom food (should work)

---

**Status:** Configuration files ready for manual update
**Next Step:** Update files manually, then deploy to Firebase
