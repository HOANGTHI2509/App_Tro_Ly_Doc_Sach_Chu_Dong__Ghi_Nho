import 'package:flutter/material.dart';
import 'add_friend_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vòng trong tin cậy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search, size: 28),
                        ),
                        IconButton(
                          onPressed: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddFriendScreen()),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1, color: Color(0xFFFF5722), size: 28),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Suggestions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gợi ý cho bạn',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Xem tất cả',
                      style: TextStyle(color: Colors.red[400], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  children: [
                    _buildSuggestionCard(
                      'Tư duy nhanh c..',
                      'Daniel Kahneman',
                      'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1317793965i/11468377.jpg',
                    ),
                    _buildSuggestionCard(
                      'Sapiens',
                      'Yuval Noah Harari',
                      'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1420585954i/23692271.jpg',
                    ),
                    _buildSuggestionCard(
                      'Nhà Giả Kim',
                      'Paulo Coelho',
                      'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1483412266i/865.jpg',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Feed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPostItem(
                      type: PostType.review,
                      userName: 'Minh anh',
                      action: 'vừa đọc xong',
                      timeAgo: '2 giờ trước',
                      userAvatarUrl: 'https://i.pravatar.cc/150?u=minhanh',
                      bookTitle: 'Dám bị ghét',
                      bookAuthor: 'Kishimi Ichiro',
                      bookImageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1516086883i/38128362.jpg',
                      rating: 4,
                      quote: '“ Cuộc đời không phức tạp chính bạn làm cho nó phức tạp. Tự do thực sự là khi ta dám bị người khác ghét bỏ. ”',
                      likeCount: 12,
                    ),
                    const SizedBox(height: 20),
                    _buildPostItem(
                      type: PostType.wantToRead,
                      userName: 'Hoàng nam',
                      action: 'thêm vào Muốn đọc',
                      timeAgo: '5 giờ trước',
                      userAvatarUrl: 'https://i.pravatar.cc/150?u=hoangnam',
                      bookTitle: 'Nghệ thuật tinh tế',
                      bookAuthor: 'Mark Mason',
                      bookImageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1482055622i/19125026.jpg',
                      likeCount: 5,
                    ),
                     const SizedBox(height: 20),
                    _buildPostItem(
                      type: PostType.note,
                      userName: 'Lan chi',
                      action: 'tạo ghi chú mới',
                      timeAgo: '1 ngày trước',
                      userAvatarUrl: 'https://i.pravatar.cc/150?u=lanchi',
                      noteTitle: 'Atomic Habits',
                      notePage: 112,
                      noteContent: 'Môi trường xung quanh quan trọng hơn ý chí. Muốn thay đổi thói quen hay thiết kế lại không gian sống của bản thân.',
                      likeCount: 5,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String author, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(author, style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBE5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPostItem({
    required PostType type,
    required String userName,
    required String action,
    required String timeAgo,
    required String userAvatarUrl,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    int? rating,
    String? quote,
    String? noteTitle,
    int? notePage,
    String? noteContent,
    required int likeCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userAvatarUrl),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                       style: const TextStyle(color: Colors.black, fontSize: 14),
                       children: [
                         TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                         TextSpan(text: ' $action', style: TextStyle(color: Colors.grey[600])),
                       ]
                    ),
                  ),
                  Text(timeAgo, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 15),

          // Content Body based on Type
          if (type == PostType.note)
             Container(
               padding: const EdgeInsets.all(15),
               decoration: BoxDecoration(
                 color: const Color(0xFFFFFDE7), // Light yellow
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                        Text(noteTitle ?? '', style: const TextStyle(color: Color(0xFFFF7043), fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                         Text('Trang $notePage', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                     ],
                   ),
                   const SizedBox(height: 10),
                   Container(width: double.infinity, height: 1, color: Colors.orange.withOpacity(0.2)),
                   const SizedBox(height: 10),
                   Text(
                     noteContent ?? '',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                   ),
                 ],
               ),
             )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      bookImageUrl ?? '',
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(width: 50, height: 75, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookTitle ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(bookAuthor ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        if (rating != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14))),
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
          
          if (quote != null) ...[
             const SizedBox(height: 15),
             Text(quote, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 13)),
          ],

          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.grey[300], size: 20),
              const SizedBox(width: 5),
              Text('$likeCount', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(width: 20),
               if (type == PostType.review) ...[
                  Icon(Icons.chat_bubble_outline, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 5),
                  Text('Bình luận', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
               ],
               if (type == PostType.wantToRead) ...[
                  const Icon(Icons.add, color: Colors.grey, size: 18),
                  const Text('cùng đọc', style: TextStyle(color: Colors.grey, fontSize: 12)),
               ]
            ],
          )
        ],
      ),
    );
  }
}

enum PostType { review, wantToRead, note }
