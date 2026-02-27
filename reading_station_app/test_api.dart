import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = 'trí tuệ người do thái';
  final url = 'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=10&printType=books';
  
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List?;
      if (items != null && items.isNotEmpty) {
        for (var item in items) {
           final volumeInfo = item['volumeInfo'];
           print('Title: ${volumeInfo['title']}');
           print('ImageLinks: ${volumeInfo['imageLinks']}');
           print('---');
        }
      } else {
        print('No items found');
      }
    } else {
      print('Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
