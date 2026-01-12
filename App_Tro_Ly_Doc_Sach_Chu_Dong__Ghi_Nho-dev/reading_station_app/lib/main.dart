import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghi chú',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFFFF9800), // màu cam
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final tabs = ['Tất cả', 'Atomic Habits', 'Tư duy nhanh và chậm'];

  final notes = [
    Note(
      book: 'Atomic Habits',
      page: 140,
      quote: 'Mục tiêu là để chiến thắng trò chơi, hệ thống là để tiếp tục trò chơi. Đừng tập trung vào đích đến, mà hãy tập trung vào quy trình.',
      time: '2 giờ trước',
      created: false,
    ),
    Note(
      book: 'Tư duy nhanh và chậm',
      page: 60,
      quote: 'Hệ thống 1 hoạt động tự động và nhanh chóng, với ít không cần nỗ lực và không cảm giác kiểm soát tự nguyện.',
      time: 'Hôm qua',
      created: true,
    ),
    Note(
      book: 'Atomic Habits',
      page: 15,
      quote: 'Nếu bạn muốn có kết quả tốt hơn thì hãy quên việc đặt mục tiêu đi. Thay vào đó hãy tập trung vào hệ thống của bạn',
      time: 'ngày 20/10',
      created: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  List<Note> filteredNotes(String tab) {
    if (tab == 'Tất cả') return notes;
    return notes.where((n) => n.book == tab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) {
          final data = filteredNotes(tab);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) => NoteCard(note: data[i]),
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Thư viện'),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: 'Ghi chú'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Ôn Tập'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Cộng đồng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}

class Note {
  final String book;
  final int page;
  final String quote;
  final String time;
  final bool created;

  Note({required this.book, required this.page, required this.quote, required this.time, required this.created});
}

class NoteCard extends StatelessWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh minh họa tạm thời
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 40, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(note.book, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Trang ${note.page}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.quote,
                  style: const TextStyle(fontSize: 15),
                  softWrap: true,
                ),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(note.time, style: const TextStyle(color: Colors.grey)),
            note.created
                ? OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Text('✅', style: TextStyle(fontSize: 16)),
                    label: const Text('Đã tạo thẻ'),
                  )
                : ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Text('⚡', style: TextStyle(fontSize: 16)),
                    label: const Text('Tạo FlashCard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ],
        ),
      ]),
    );
  }
}