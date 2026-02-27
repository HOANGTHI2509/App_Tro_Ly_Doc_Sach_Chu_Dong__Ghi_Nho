import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/note_controller.dart';
import '../../models/note.dart';

class ReadingNoteScreen extends StatefulWidget {
  final String bookTitle;

  const ReadingNoteScreen({
    super.key,
    required this.bookTitle,
  });

  @override
  State<ReadingNoteScreen> createState() => _ReadingNoteScreenState();
}

class _ReadingNoteScreenState extends State<ReadingNoteScreen> {
  final NoteController _noteController = NoteController();
  // Highlighted text ranges
  final List<TextRange> _highlights = [];

  // Book content matching Figma design
  static const String _bookContent =
      'Đêm thứ nhất: Hãy phủ định trấn thương tâm lí.\n\n'
      'Mọi phiền muộn đều bắt nguồn từ mối quan hệ giữa người với người ?\n\n'
      'TRIẾT GIA : Đúng vậy đây là một khái niệm rất quan trọng trong tâm lý học '
      'Adler. Nếu mọi quan hệ giữa người với người biến mất khỏi thế giới này ,'
      'nghĩa là trôn vũ trụ này không có ai khác chỉ có mình ta ,thì mọi buồn '
      'phiền cũng sẽ biến mất.\n\n'
      'Bởi vì tất cả cái loại phiền muộn nào cũng là phiền muộn giữa người với người.\n\n'
      'CHÀNG THANH NIÊN : Chỉ cần mối quan hệ giữa người với người biến mất thì '
      'muộn phiền cũng biến mất.Điều đó có thể sao ?\n\n'
      'TRIẾT GIA : Dĩ nhiên, xóa bỏ hoàn toàn mối quan hệ giữa người với người '
      'là điều không thể.Con người về bản chất';

  // Pre-computed bold format ranges
  late final List<_FormatRange> _formatRanges;

  @override
  void initState() {
    super.initState();
    _formatRanges = _computeFormatRanges();

    // Demo highlight matching Figma (bold italic line)
    const demoText =
        'Bởi vì tất cả cái loại phiền muộn nào cũng là phiền muộn giữa người với người.';
    final idx = _bookContent.indexOf(demoText);
    if (idx >= 0) {
      _highlights.add(TextRange(start: idx, end: idx + demoText.length));
    }
  }

  List<_FormatRange> _computeFormatRanges() {
    final List<_FormatRange> ranges = [];

    // Title line
    final titleEnd = _bookContent.indexOf('\n');
    if (titleEnd > 0) {
      ranges.add(_FormatRange(0, titleEnd, isBold: true, fontSize: 22));
    }

    // Dialog speaker labels
    for (final pattern in ['TRIẾT GIA : ', 'CHÀNG THANH NIÊN : ']) {
      int searchFrom = 0;
      while (true) {
        final idx = _bookContent.indexOf(pattern, searchFrom);
        if (idx < 0) break;
        ranges.add(_FormatRange(idx, idx + pattern.length, isBold: true));
        searchFrom = idx + pattern.length;
      }
    }

    // Bold emphasis line
    const emphasis =
        'Bởi vì tất cả cái loại phiền muộn nào cũng là phiền muộn giữa người với người.';
    final emphIdx = _bookContent.indexOf(emphasis);
    if (emphIdx >= 0) {
      ranges.add(_FormatRange(emphIdx, emphIdx + emphasis.length,
          isBold: true, isItalic: true));
    }

    return ranges;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.bookTitle,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SelectableText.rich(
          _buildTextSpan(),
          contextMenuBuilder: _buildContextMenu,
        ),
      ),
    );
  }

  // Custom context menu with Sao chép, Tô màu, Tạo ghi chú
  Widget _buildContextMenu(
      BuildContext context, EditableTextState editableTextState) {
    final value = editableTextState.textEditingValue;
    final selectedText = value.selection.isValid && !value.selection.isCollapsed
        ? value.selection.textInside(value.text)
        : '';

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: [
        ContextMenuButtonItem(
          label: 'Sao chép',
          onPressed: () {
            if (selectedText.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: selectedText));
            }
            editableTextState.hideToolbar();
          },
        ),
        ContextMenuButtonItem(
          label: 'Tô màu',
          onPressed: () {
            if (value.selection.isValid && !value.selection.isCollapsed) {
              setState(() {
                _highlights.add(TextRange(
                  start: value.selection.start,
                  end: value.selection.end,
                ));
              });
            }
            editableTextState.hideToolbar();
          },
        ),
        ContextMenuButtonItem(
          label: 'Tạo ghi chú',
          onPressed: () {
            editableTextState.hideToolbar();
            if (selectedText.isNotEmpty) {
              _showCreateNoteSheet(selectedText);
            }
          },
        ),
      ],
    );
  }

  // Build TextSpan with formatting + highlights
  TextSpan _buildTextSpan() {
    final text = _bookContent;
    final len = text.length;

    // Collect boundary points
    final Set<int> boundaries = {0, len};
    for (final f in _formatRanges) {
      boundaries.add(f.start.clamp(0, len));
      boundaries.add(f.end.clamp(0, len));
    }
    for (final h in _highlights) {
      boundaries.add(h.start.clamp(0, len));
      boundaries.add(h.end.clamp(0, len));
    }

    final sorted = boundaries.toList()..sort();
    final List<TextSpan> spans = [];

    for (int i = 0; i < sorted.length - 1; i++) {
      final s = sorted[i];
      final e = sorted[i + 1];
      if (s >= e || s >= len) continue;
      final actualEnd = e.clamp(0, len);

      bool isBold = false;
      bool isItalic = false;
      double fontSize = 16;
      bool isHighlighted = false;

      for (final f in _formatRanges) {
        if (f.start <= s && actualEnd <= f.end) {
          isBold = f.isBold;
          isItalic = f.isItalic;
          fontSize = f.fontSize;
        }
      }
      for (final h in _highlights) {
        if (h.start <= s && actualEnd <= h.end) {
          isHighlighted = true;
        }
      }

      spans.add(TextSpan(
        text: text.substring(s, actualEnd),
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          fontSize: fontSize,
          height: 1.8,
          color: Colors.black87,
          backgroundColor: isHighlighted ? const Color(0xFFB3E5FC) : null,
        ),
      ));
    }

    return TextSpan(children: spans);
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Đánh dấu trang'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Cỡ chữ'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Chia sẻ'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateNoteSheet(String selectedText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool createFlashcard = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tạo ghi chú',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Selected text preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"$selectedText"',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Book info
                  Row(
                    children: [
                      const Text('Cuốn sách',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text(widget.bookTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                  const Divider(height: 24),

                  // Flashcard toggle
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tạo flashcard',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            Text('Tự động thêm vào lịch ôn tập',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: createFlashcard,
                        onChanged: (v) => setSheetState(() => createFlashcard = v),
                        activeTrackColor: const Color(0xFFFF5722),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                        final note = Note(
                          userId: userId,
                          bookTitle: widget.bookTitle,
                          content: selectedText,
                          hasFlashcard: createFlashcard,
                        );
                        
                        final navigator = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        
                        await _noteController.addNote(note);
                        
                        if (context.mounted) {
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Đã tạo ghi chú thành công!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Lưu ghi chú',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Helper class for text format ranges
class _FormatRange {
  final int start;
  final int end;
  final bool isBold;
  final bool isItalic;
  final double fontSize;

  _FormatRange(this.start, this.end,
      {this.isBold = false, this.isItalic = false, this.fontSize = 16});
}
