import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/review_provider.dart';
import '../../models/note.dart';
import 'flashcard_review_screen.dart';
import 'add_flashcard_screen.dart';
import '../notes/add_note_screen.dart';
import '../../providers/note_provider.dart';
import '../../providers/review_settings_provider.dart';
import 'deck_detail_widget.dart';
import 'review_settings_screen.dart';
import '../../providers/user_profile_provider.dart';

class SelectedDeckNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}
final selectedDeckTitleProvider = NotifierProvider<SelectedDeckNotifier, String?>(SelectedDeckNotifier.new);

class IsDueModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}
final isDueModeProvider = NotifierProvider<IsDueModeNotifier, bool>(IsDueModeNotifier.new);

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  final Color _primaryGreen = const Color(0xFF568164);
  final Color _lightBg = const Color(0xFFFAF9F6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers from review_provider.dart
    final dueNotesAsync = ref.watch(dueNotesProvider);
    final totalNotesCountAsync = ref.watch(totalNotesCountProvider);
    final memorizedCountAsync = ref.watch(memorizedNotesCountProvider);
    final streakAsync = ref.watch(streakProvider);
    final allNotesTopAsync = ref.watch(allNotesProvider);
    
    // New Feature: Deck Detail Logic
    final selectedDeckTitle = ref.watch(selectedDeckTitleProvider);
    final isDueMode = ref.watch(isDueModeProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final String? avatarUrl = profileAsync.value?['avatar_url'];
    final String name = profileAsync.value?['name'] ?? 'A';

    if (selectedDeckTitle != null) {
      return allNotesTopAsync.when(
        data: (notes) {
          // get all flashcards for this book
          final flashcards = notes.where((n) {
             // flashcards are those with at least a nextReview timestamp OR question
             return n.bookTitle == selectedDeckTitle && (n.nextReview != null || (n.question != null && n.question!.isNotEmpty));
          }).toList();
          
          if (flashcards.isEmpty) { // fallback
            return Scaffold(
              backgroundColor: _lightBg,
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: const Center(child: Text("Không có thẻ trong bộ này")),
            );
          }
          final firstNote = flashcards.first;
          
          return Scaffold(
            backgroundColor: _lightBg,
            body: SafeArea(
              child: DeckDetailWidget(
                title: selectedDeckTitle,
                author: firstNote.bookAuthor,
                imageUrl: firstNote.bookImageUrl,
                notes: flashcards,
                isDueMode: isDueMode,
                onBack: () => ref.read(selectedDeckTitleProvider.notifier).state = null,
              ),
            ),
          );
        },
        loading: () => Scaffold(backgroundColor: _lightBg, body: const Center(child: CircularProgressIndicator())),
        error: (e, __) => Scaffold(backgroundColor: _lightBg, body: Center(child: Text('Lỗi: $e'))),
      );
    }
    
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
             ref.invalidate(dueNotesProvider);
             ref.invalidate(totalNotesCountProvider);
             ref.invalidate(memorizedNotesCountProvider);
             ref.invalidate(allNotesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                _AnimatedReviewItem(
                  index: 0,
                  animateSlide: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Color(0xFF2C3E35)),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      Text(
                        'Ôn tập',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _primaryGreen,
                          fontFamily: 'Serif',
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.settings_outlined, color: Colors.grey[600]),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewSettingsScreen()));
                            },
                          ),
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: _primaryGreen,
                            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                            child: (avatarUrl == null || avatarUrl.isEmpty)
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
          
                // Hero Card: Nhiệm vụ hôm nay
                _AnimatedReviewItem(
                  index: 1,
                  child: dueNotesAsync.when(
                    data: (notes) => _buildHeroCard(context, notes, _primaryGreen),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, __) => Text('Lỗi: $e'),
                  ),
                ),
                
                const SizedBox(height: 24),
          
                // Stats Row
                _AnimatedReviewItem(
                  index: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: streakAsync.when(
                          data: (streak) => _buildStatCard('$streak ngày', 'CHUỖI', const Color(0xFFFAEDE3), Icons.local_fire_department_rounded, Colors.orange[800]!),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Text('Lỗi'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: memorizedCountAsync.when(
                          data: (count) => _buildStatCard(count.toString(), 'ĐÃ THUỘC', const Color(0xFFE8F1EB), Icons.check_circle_rounded, _primaryGreen),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: totalNotesCountAsync.when(
                          data: (count) => _buildStatCard(count.toString(), 'TỔNG SỐ', const Color(0xFFF9F1E6), Icons.layers_rounded, const Color(0xFF2C3E35)),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
          
                // Bộ thẻ cần ôn Header
                _AnimatedReviewItem(
                  index: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ thẻ cần ôn',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF1B263B)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Xem tất cả', style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
          
                // List of decks from due notes
                dueNotesAsync.when(
                  data: (notes) {
                    if (notes.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: _AnimatedReviewItem(
                            index: 4,
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text('Chưa có thẻ nào cần ôn hôm nay!', style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Group notes by book
                    final grouped = <String, List<Note>>{};
                    for (var note in notes) {
                      grouped.update(note.bookTitle, (list) => list..add(note), ifAbsent: () => [note]);
                    }
                    
                    return Column(
                      children: grouped.entries.toList().asMap().entries.map((mapEntry) {
                        int index = mapEntry.key;
                        var entry = mapEntry.value;
                        final bookNotes = entry.value;
                        final firstNote = bookNotes.first;
                        return _AnimatedReviewItem(
                          index: 4 + index,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref.read(isDueModeProvider.notifier).state = true;
                                  ref.read(selectedDeckTitleProvider.notifier).state = entry.key;
                                },
                                child: _buildDeckItem(
                                  title: entry.key,
                                  author: firstNote.bookAuthor,
                                  cardCount: bookNotes.length,
                                  imageUrl: firstNote.bookImageUrl,
                                  color: const Color(0xFFF3E5BC),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                
                const SizedBox(height: 24),
                
                // Bộ thẻ đã tạo Header
                _AnimatedReviewItem(
                  index: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ thẻ đã tạo',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF1B263B)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Xem tất cả', style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // List of ALL decks
                allNotesTopAsync.when(
                  data: (notes) {
                    final flashcards = notes.where((n) {
                       return n.nextReview != null || (n.question != null && n.question!.isNotEmpty);
                    }).toList();

                    if (flashcards.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: _AnimatedReviewItem(
                            index: 7,
                            child: Text('Chưa có bộ thẻ nào được tạo!', style: TextStyle(color: Colors.grey[500]))
                          ),
                        ),
                      );
                    }
                    
                    // Group notes by book
                    final grouped = <String, List<Note>>{};
                    for (var note in flashcards) {
                      grouped.update(note.bookTitle, (list) => list..add(note), ifAbsent: () => [note]);
                    }
                    
                    return Column(
                      children: grouped.entries.toList().asMap().entries.map((mapEntry) {
                        int index = mapEntry.key;
                        var entry = mapEntry.value;
                        final bookNotes = entry.value;
                        final firstNote = bookNotes.first;
                        return _AnimatedReviewItem(
                          index: 7 + index,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref.read(isDueModeProvider.notifier).state = false;
                                  ref.read(selectedDeckTitleProvider.notifier).state = entry.key;
                                },
                                child: _buildDeckItem(
                                  title: entry.key,
                                  author: firstNote.bookAuthor,
                                  cardCount: bookNotes.length,
                                  imageUrl: firstNote.bookImageUrl,
                                  color: const Color(0xFFE8F1EB), // Light green to differentiate
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                ),
                
                const SizedBox(height: 40),
                Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.eco, size: 60, color: _primaryGreen),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'review_fab',
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddFlashcardScreen()));
        },
        backgroundColor: _primaryGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, List<Note> notes, Color primaryColor) {
    final count = notes.length;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'NHIỆM VỤ HÔM NAY',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.access_time_filled, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('~${(count * 0.5).ceil()} phút', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$count thẻ cần ôn',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B263B),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count > 0 
              ? 'Bạn có $count thẻ cần được ôn luyện để ghi nhớ sâu hơn vào bộ nhớ dài hạn.'
              : 'Tất cả các thẻ đã được ôn luyện xanh mướt! Quay lại sau nhé.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.of(context).push(MaterialPageRoute(builder: (context) => FlashcardReviewScreen(notes: notes)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Bắt đầu ôn tập',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bgColor, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1B263B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckItem({
    required String title,
    required String author,
    required int cardCount,
    required String imageUrl,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (imageUrl.isNotEmpty) 
              ? Image.network(
                  imageUrl,
                  height: 70,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], height: 70, width: 50),
                )
              : Container(color: Colors.grey[200], height: 70, width: 50),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B263B)),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$cardCount thẻ',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

class _AnimatedReviewItem extends StatefulWidget {
  final Widget child;
  final int index;
  final bool animateSlide;

  const _AnimatedReviewItem({Key? key, required this.child, required this.index, this.animateSlide = true}) : super(key: key);

  @override
  State<_AnimatedReviewItem> createState() => _AnimatedReviewItemState();
}

class _AnimatedReviewItemState extends State<_AnimatedReviewItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _slideAnimation = Tween<Offset>(begin: widget.animateSlide ? const Offset(0.0, 0.15) : Offset.zero, end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
