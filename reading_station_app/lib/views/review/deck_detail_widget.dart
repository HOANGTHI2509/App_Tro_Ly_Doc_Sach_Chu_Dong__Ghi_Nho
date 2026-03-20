import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import 'flashcard_review_screen.dart';
import 'add_flashcard_screen.dart';

class DeckDetailWidget extends StatefulWidget {
  final String title;
  final String author;
  final String imageUrl;
  final List<Note> notes;
  final bool isDueMode;
  final VoidCallback onBack;

  const DeckDetailWidget({
    Key? key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.notes,
    this.isDueMode = false,
    required this.onBack,
  }) : super(key: key);

  @override
  State<DeckDetailWidget> createState() => _DeckDetailWidgetState();
}

class _DeckDetailWidgetState extends State<DeckDetailWidget> {
  final Color _primaryGreen = const Color(0xFF568164);
  final Color _lightBg = const Color(0xFFFAF9F6);
  String _filter = 'Tất cả'; // 'Tất cả', 'Cần ôn', 'Đã thuộc'

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    int needReview = widget.notes.where((n) {
      if (n.nextReview == null) return true;
      return n.nextReview!.isBefore(DateTime.now());
    }).length;

    int memorized = widget.notes.where((n) {
      if (n.nextReview == null) return false;
      return n.nextReview!.isAfter(DateTime.now());
    }).length;

    double progress = widget.notes.isEmpty 
        ? 0 
        : (memorized / widget.notes.length * 100);

    // Filter notes
    List<Note> filteredNotes = widget.notes.where((n) {
      bool isNeedReview = n.nextReview == null || n.nextReview!.isBefore(DateTime.now());
      if (_filter == 'Cần ôn') return isNeedReview;
      if (_filter == 'Đã thuộc') return !isNeedReview;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton( // Nút Back
                icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
                onPressed: widget.onBack,
              ),
              Text(
                'Trạm Đọc', // Title App
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                  fontFamily: 'Serif',
                ),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
              ),
            ],
          ),
        ),

        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0), // Padding bottom reduced since FAB is gone
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover Card
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.imageUrl.isNotEmpty
                              ? Image.network(
                                  widget.imageUrl,
                                  height: 140,
                                  width: 95,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                                )
                              : _buildPlaceholderImage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tags
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E5D1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('PREMIUM V2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B6B4A))),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(Icons.style, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.isDueMode ? '$needReview Thẻ cần ôn' : '${widget.notes.length} Thẻ', 
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title & Desc
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF1B263B)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hệ thống các thói quen nhỏ giúp thay đổi cuộc đời. Bộ thẻ tập trung vào 4 định luật thay đổi hành vi và các chiến lược duy trì kỷ luật.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (needReview > 0) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const FlashcardReviewScreen()
                              ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không có thẻ nào cần ôn!')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                            label: const Text('Bắt đầu ôn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (!widget.isDueMode) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddFlashcardScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEFECE5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.add_circle, color: Color(0xFF568164), size: 20),
                              label: const Text('Thêm thẻ', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),

                    if (!widget.isDueMode) ...[
                      // Stats Area Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F3ED),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem('TIẾN BỘ', '${progress.toInt()}%', _primaryGreen),
                                Container(height: 40, width: 1, color: Colors.grey[300]),
                                _buildStatItem('CẦN ÔN', '$needReview', const Color(0xFFCC3333)),
                                Container(height: 40, width: 1, color: Colors.grey[300]),
                                _buildStatItem('ĐÃ THUỘC', '$memorized', const Color(0xFF8B6B4A)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Filters
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBE8E1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  _buildFilterButton('Tất cả'),
                                  _buildFilterButton('Cần ôn'),
                                  _buildFilterButton('Đã thuộc'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Flashcard List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredNotes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return _buildCardItem(note);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      height: 140,
      width: 95,
      child: const Icon(Icons.book, color: Colors.grey, size: 40),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: valueColor, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildFilterButton(String label) {
    bool isSelected = _filter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(Note note) {
    bool isNeedReview = note.nextReview == null || note.nextReview!.isBefore(DateTime.now());
    
    // Attempting to extract tags if available or generic label
    String category = (note.tags != null && note.tags!.isNotEmpty) 
        ? note.tags!.first.toUpperCase() 
        : 'THẺ GHI NHỚ';
        
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryGreen, letterSpacing: 0.5)),
              if (isNeedReview)
                const Text('!', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16))
              else
                const Icon(Icons.check_circle, color: Colors.grey, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.question ?? note.content, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF1B263B)),
          ),
          if (note.question != null && note.question!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Gợi ý: ${note.content.length > 50 ? "${note.content.substring(0, 50)}..." : note.content}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isNeedReview ? Colors.grey[200] : const Color(0xFFF3E5BC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isNeedReview ? 'Cần ôn' : 'Đã thuộc',
              style: TextStyle(fontSize: 11, color: isNeedReview ? Colors.grey[700] : const Color(0xFF8B6B4A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
