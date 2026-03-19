import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String query = 'Đắc Nhân Tâm';
  const String apiKey = 'AIzaSyC9bjjql9PvstS0dn5z6l2yzYR-vLs2Jcs';
  final url = 'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=5&key=$apiKey';
  
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null) {
        for (var item in data['items']) {
          final volumeInfo = item['volumeInfo'] ?? {};
          final title = volumeInfo['title'];
          final imageLinks = volumeInfo['imageLinks'];
          print('Title: $title');
          print('ImageLinks: $imageLinks');
          if (imageLinks != null) {
            print('Thumbnail: ${imageLinks['thumbnail']}');
          }
          print('---');
        }
      }
    } else {
      print('Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
