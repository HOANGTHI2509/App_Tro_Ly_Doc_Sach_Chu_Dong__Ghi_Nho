import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> searchBooks(String query) async {
    try {
      // Added printType=books to get better results
      final response = await http.get(Uri.parse('$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=20&printType=books'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          final items = data['items'] as List;
          return items.map((item) => Book.fromGoogleApi(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }

  Future<Book?> getBookByIsbn(String isbn) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?q=isbn:$isbn'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && (data['items'] as List).isNotEmpty) {
           return Book.fromGoogleApi(data['items'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error getting book by ISBN: $e');
      return null;
    }
  }
}
