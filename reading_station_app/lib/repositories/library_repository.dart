import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_book.dart';

class LibraryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the current user's library collection
  CollectionReference get _libraryCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(user.uid).collection('library');
  }

  // Get stream of all user books
  Stream<List<UserBook>> getUserBooks() {
    try {
      return _libraryCollection
          .orderBy('dateAdded', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => UserBook.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error getting user books: $e');
      return Stream.value([]);
    }
  }

  // Add a new book to the library
  Future<void> addBook(UserBook userBook) async {
    try {
      await _libraryCollection.add(userBook.toFirestore());
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  // Update an existing book (e.g. progress, status)
  Future<void> updateBook(UserBook userBook) async {
    try {
      print('Starting updateBook for id: ${userBook.id}');
      await _libraryCollection.doc(userBook.id).set(
        userBook.toFirestore(),
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 5));
      print('Successfully updated book');
    } catch (e) {
       print('Error updating book in repository: $e');
       rethrow;
    }
  }

  // Remove a book
  Future<void> removeBook(String bookId) async {
    try {
      await _libraryCollection.doc(bookId).delete();
    } catch (e) {
       print('Error removing book: $e');
       rethrow;
    }
  }
}
