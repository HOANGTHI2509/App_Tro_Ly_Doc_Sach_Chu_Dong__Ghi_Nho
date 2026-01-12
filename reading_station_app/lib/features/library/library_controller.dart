import 'package:flutter/material.dart';
import '../../models/book_model.dart'; // Lùi 2 cấp ra models

class LibraryController extends ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  final List<Book> _allBooks = [
    Book(id: '1', title: "Nhà Giả Kim", author: "Paulo Coelho", coverUrl: "https://upload.wikimedia.org/wikipedia/vi/9/98/NhagiaKim.jpg", status: BookStatus.reading, currentPage: 120, totalPages: 283),
    Book(id: '2', title: "Thép đã tôi thế đấy", author: "Nikolai Ostrovsky", coverUrl: "https://upload.wikimedia.org/wikipedia/vi/thumb/9/90/Th%C3%A9p_%C4%91%C3%A3_t%C3%B4i_th%E1%BA%BF_%C4%91%E1%BA%A5y_-_B%C3%ACa_s%C3%A1ch_c%E1%BB%A7a_NXB_V%C4%83n_h%E1%BB%8Dc.jpg/220px-Th%C3%A9p_%C4%91%C3%A3_t%C3%B4i_th%E1%BA%BF_%C4%91%E1%BA%A5y_-_B%C3%ACa_s%C3%A1ch_c%E1%BB%A7a_NXB_V%C4%83n_h%E1%BB%8Dc.jpg", status: BookStatus.wantToRead, totalPages: 300, genre: "Tiểu thuyết"),
    Book(id: '3', title: "Trí tuệ Do Thái", author: "Eran Katz", coverUrl: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1344686737i/15822394.jpg", status: BookStatus.read, rating: 5.0, finishedDate: "20/12/2025"),
  ];

  List<Book> get filteredBooks {
    if (_currentTabIndex == 0) return _allBooks.where((b) => b.status == BookStatus.reading).toList();
    if (_currentTabIndex == 1) return _allBooks.where((b) => b.status == BookStatus.wantToRead).toList();
    return _allBooks.where((b) => b.status == BookStatus.read).toList();
  }

  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
