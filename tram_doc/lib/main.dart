import 'package:flutter/material.dart';
// Import file bạn vừa tạo ở đây
import 'package:tram_doc/Account/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trạm Đọc',
      theme: ThemeData(primarySwatch: Colors.orange),
      // Gọi màn hình LoginScreen
      home: const LoginScreen(),
    );
  }
}
