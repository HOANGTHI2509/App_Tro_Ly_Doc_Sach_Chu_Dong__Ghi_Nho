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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm sách',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(searchBooksProvider.notifier).onChangeQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Nhập tên sách, tác giả...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFF5722)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
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
            Icon(Icons.menu_book_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tìm sách để thêm vào thư viện',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
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
            child: Center(child: CircularProgressIndicator(color: Color(0xFFFF5722))),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (book.genre != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.genre!,
                        style: const TextStyle(
                          color: Color(0xFFFF5722),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 16),
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
