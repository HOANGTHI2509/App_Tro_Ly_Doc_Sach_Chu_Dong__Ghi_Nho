import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = 'Nhà Giả Kim';
  final url = 'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=20';
  print('Fetching: $url');
  try {
    final response = await http.get(Uri.parse(url));
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Total Items: ${data['totalItems']}');
      if (data['items'] != null) {
        final items = data['items'] as List;
        print('Returned items: ${items.length}');
        for (var item in items.take(2)) {
          final volumeInfo = item['volumeInfo'];
          print('- Title: ${volumeInfo['title']}');
        }
      } else {
        print('Items array is NULL');
      }
    } else {
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
