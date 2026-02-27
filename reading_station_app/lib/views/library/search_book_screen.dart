import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'book_details_screen.dart';
import '../../../models/book.dart';
import '../../../services/api_service.dart';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';

final searchApiProvider = Provider((ref) => ApiService());

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String value) {
    state = value;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final searchResultsProvider = FutureProvider<List<Book>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final api = ref.watch(searchApiProvider);
  return api.searchBooks(query);
});

class SearchBookScreen extends ConsumerWidget {
  const SearchBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController(text: ref.read(searchQueryProvider));
    final resultsAsyncValue = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tìm kiếm sách', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFFF8F9FA),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ]
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên sách, tác giả...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFF5722)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFFFF5722)),
                    onPressed: () {
                       ref.read(searchQueryProvider.notifier).updateQuery(searchController.text);
                       FocusScope.of(context).unfocus();
                    },
                  )
                ),
                onSubmitted: (value) {
                  ref.read(searchQueryProvider.notifier).updateQuery(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: resultsAsyncValue.when(
              data: (books) {
                if (books.isEmpty && ref.watch(searchQueryProvider).isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Không tìm thấy sách nào.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  );
                }
                if (books.isEmpty) {
                   return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Tìm sách để thêm vào thư viện', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: books.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _buildSearchResultItem(context, ref, book);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722))),
              error: (err, stack) => Center(child: Text('Đã có lỗi xảy ra: $err', style: const TextStyle(color: Colors.red))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(BuildContext context, WidgetRef ref, Book book) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)));
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
          ]
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.imageUrl.isNotEmpty
                ? Image.network(book.imageUrl, width: 65, height: 95, fit: BoxFit.cover, errorBuilder: (_,__,___) => _defaultCover())
                : _defaultCover(),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (book.genre != null) ...[
                     const SizedBox(height: 8),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(color: const Color(0xFFFFEBE5), borderRadius: BorderRadius.circular(8)),
                       child: Text(book.genre!, style: const TextStyle(color: Color(0xFFFF5722), fontSize: 10, fontWeight: FontWeight.bold)),
                     )
                  ]
                ],
              )
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 16),
            ),
          ],
        )
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 65, height: 95, color: Colors.grey[200],
      child: Icon(Icons.book, color: Colors.grey[400])
    );
  }
}
