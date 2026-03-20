import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'book_details_screen.dart';
import '../../../models/book.dart';
import '../../../services/api_service.dart';
import '../../../providers/library_provider.dart';

// --- Search State ---
class SearchState {
  final List<Book> books;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String query;
  final String? error;

  const SearchState({
    this.books = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.query = '',
    this.error,
  });

  SearchState copyWith({
    List<Book>? books,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? query,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// --- Notifier ---
final searchApiProvider = Provider<ApiService>((ref) => ApiService());

class SearchBooksNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return const SearchState();
  }

  void onChangeQuery(String query) {
    if (query == state.query) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true, clearError: true, books: []);

    _debounce = Timer(const Duration(milliseconds: 800), () {
      _searchInitial(query);
    });
  }

  Future<void> _searchInitial(String query) async {
    try {
      final api = ref.read(searchApiProvider);
      var fetchedBooks = await api.searchBooks(query, startIndex: 0);
      
      // Filter results to be more relevant if the query is specific
      if (query.length > 3) {
        final lowerQuery = query.toLowerCase();
        fetchedBooks = fetchedBooks.where((book) {
          final lowerTitle = book.title.toLowerCase();
          return lowerTitle.contains(lowerQuery);
        }).toList();
      }

      state = SearchState(
        books: fetchedBooks,
        query: query,
        hasReachedMax: fetchedBooks.length < 10,
        isLoading: false,
      );
    } catch (e) {
      state = SearchState(query: query, error: e.toString());
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || state.hasReachedMax || state.query.isEmpty || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final api = ref.read(searchApiProvider);
      var newBooks = await api.searchBooks(
        state.query,
        startIndex: state.books.length,
      );

      // Filter results to be more relevant if the query is specific
      if (state.query.length > 3) {
        final lowerQuery = state.query.toLowerCase();
        newBooks = newBooks.where((book) {
          final lowerTitle = book.title.toLowerCase();
          return lowerTitle.contains(lowerQuery);
        }).toList();
      }

      if (newBooks.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasReachedMax: true);
      } else {
        state = state.copyWith(
          books: [...state.books, ...newBooks],
          isLoadingMore: false,
          hasReachedMax: newBooks.length < 10,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final searchBooksProvider = NotifierProvider<SearchBooksNotifier, SearchState>(
  SearchBooksNotifier.new,
);

// --- UI ---
class SearchBookScreen extends ConsumerStatefulWidget {
  const SearchBookScreen({super.key});

  @override
  ConsumerState<SearchBookScreen> createState() => _SearchBookScreenState();
}

class _SearchBookScreenState extends ConsumerState<SearchBookScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = ref.read(searchBooksProvider).query;
      if (query.isNotEmpty) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchBooksProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchBooksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm sách',
          style: TextStyle(color: Color(0xFF385A46), fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif'),
        ),
        backgroundColor: const Color(0xFFF9F7F2),
        iconTheme: const IconThemeData(color: Color(0xFF4A745B)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4EDE4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(searchBooksProvider.notifier).onChangeQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Nhập tên sách, tác giả...',
                  hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFBDBDBD)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFFBDBDBD)),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchBooksProvider.notifier).onChangeQuery('');
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  ref.read(searchBooksProvider.notifier).onChangeQuery(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 60, color: Color(0xFFD4DAD0)),
            const SizedBox(height: 16),
            const Text(
              'Tìm sách để thêm vào thư viện',
              style: TextStyle(color: Color(0xFF757575), fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF568164)));
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu. Thử lại sau.',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sách nào.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: state.books.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        if (index == state.books.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF568164))),
          );
        }
        return _buildBookItem(state.books[index]);
      },
    );
  }

  Widget _buildBookItem(Book book) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2EFE9),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: book.imageUrl.isNotEmpty
                    ? Image.network(
                        book.imageUrl,
                        width: 65,
                        height: 95,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image ${book.imageUrl}: $error');
                          return _defaultCover();
                        },
                      )
                    : _defaultCover(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif', color: Color(0xFF2C3E35)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
                  ),
                  if (book.genre != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE3D5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.genre!.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 65,
      height: 95,
      color: Colors.grey[200],
      child: Icon(Icons.book, color: Colors.grey[400]),
    );
  }
}
