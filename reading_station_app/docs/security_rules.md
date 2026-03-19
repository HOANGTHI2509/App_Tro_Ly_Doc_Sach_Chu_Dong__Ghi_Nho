# 🔒 Hệ Thống Phân Quyền (Firestore Rules)

## Principles
1. **Authenticated**: Login required.
2. **Owner Only**: Writing data requires UID match.
3. **Friend Visibility**: Friends can see public notes and activities.

## Rule Breakdown
- `users`: Read by all auth users (for search), write by owner.
- `books`: Read by all auth users, write by Cloud Functions only.
- `userBooks`: Read by owner or friends, write by owner.
  - `notes`: Read by owner or friends (if public), write by owner.
- `friendships`: Read/Write by involved users.
- `activities`: Read by owner or friends (visibility based).
