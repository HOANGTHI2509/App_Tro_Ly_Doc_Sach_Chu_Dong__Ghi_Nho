# 🗄️ Thiết Kế Database (Firestore)

## Collections Overview
- `users`: User profiles, settings, and stats.
- `books`: Shared book metadata (ISBN, title, author).
- `userBooks`: Junction between User and Book (shelf, progress).
  - Subcollection `notes`: User's notes for a specific book.
  - Subcollection `keyTakeaways`: Summary ideas.
- `flashcards`: SRS cards.
- `friendships`: Two-way friend relationships.
- `activities`: Social feed events.

## Firestore Indexes
Detailed indexes for `userBooks` (userId + shelf + updatedAt), `flashcards` (userId + nextReviewDate), `friendships` (user1/2Id + status), and `activities` (userId + createdAt).
