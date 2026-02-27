import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../book_details_screen.dart';
import '../../../services/api_service.dart';
import '../../../models/book.dart';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _isProcessing = false;
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã ISBN sách', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                   setState(() { _isProcessing = true; });
                   await _handleScannedIsbn(barcode.rawValue!);
                   // Assuming we pop or resume after handling
                   if (mounted) {
                     setState(() { _isProcessing = false; });
                   }
                   break; // Process one at a time
                }
              }
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 16),
                    Text('Đang tra cứu thông tin sách...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
             // A simple scanning overlay
             Center(
              child: Container(
                width: 250,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<void> _handleScannedIsbn(String isbn) async {
     final book = await _apiService.getBookByIsbn(isbn);
     if (!mounted) return;

     if (book == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Không tìm thấy sách với mã này!'))
       );
       setState(() { _isProcessing = false; });
       return;
     }

     // Navigate to details screen
     await Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)));
     
     // After returning from details screen, re-enable scanning
     if (mounted) {
       setState(() { _isProcessing = false; });
     }
  }
}
