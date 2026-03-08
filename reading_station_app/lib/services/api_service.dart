import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../config/app_config.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const String _apiKey = AppConfig.googleBooksApiKey;

  Future<List<Book>> searchBooks(String query, {int startIndex = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=10&startIndex=$startIndex&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          final items = data['items'] as List;
          return items.map((item) {
             try {
               return Book.fromGoogleApi(item);
             } catch (e) {
               print('Error parsing individual book: $e');
               return null;
             }
          }).where((book) => book != null).cast<Book>().toList();
        }
      } else {
        print('Google API Error: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }

  Future<Book?> getBookByIsbn(String isbn) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=isbn:$isbn&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && (data['items'] as List).isNotEmpty) {
           try {
             return Book.fromGoogleApi(data['items'][0]);
           } catch (e) {
             print('Error parsing book from ISBN: $e');
             return null;
           }
        }
      } else {
        print('Google API Error on ISBN fetch: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error getting book by ISBN: $e');
      return null;
    }
  }
}
