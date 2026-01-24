import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ôn tập',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.history, color: Colors.red[400]),
                ],
              ),
              
              const SizedBox(height: 20),

              // Hero Card (Daily Task)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7043), Color(0xFF42A5F5)], // Orange to Blue gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nhiệm vụ hôm nay',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('~2 phút', style: TextStyle(color: Colors.white, fontSize: 12)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '5 thẻ',
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Kiến thức cần được "tưới nước" để xanh tốt. Sẵn sàng chưa?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFFFF5722)),
                      label: const Text(
                        'Bắt đầu ôn tập',
                        style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard('3 ngày', 'Chuỗi liên tục', const Color(0xFFFFF3E0), Icons.local_fire_department, Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard('120', 'Thẻ đã thuộc', const Color(0xFFE8F5E9), Icons.check_circle_outline, Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard('15', 'Tổng bộ thẻ', const Color(0xFFFFEBE5), Icons.layers, Colors.redAccent)),
                ],
              ),
              
              const SizedBox(height: 20),
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bộ thẻ cần ôn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () {}, 
                    child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFFFF5722), fontSize: 12)),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // Deck List
              _buildDeckItem(
                title: 'Dám bị ghét', 
                subtitle: '2 thẻ cần ôn', 
                imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1516086883i/38128362.jpg',
                isDue: true
              ),
              const SizedBox(height: 10),
              _buildDeckItem(
                title: 'Sapiens: Lược sử loài người', 
                subtitle: '3 thẻ cần ôn', 
                imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1420585954i/23692271.jpg',
                isDue: true
              ),
              const SizedBox(height: 10),
               _buildDeckItem(
                title: 'Nghĩ giàu làm giàu', 
                subtitle: 'Đã xong hôm nay', 
                imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1463241782i/30186948.jpg',
                isDue: false
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bgColor, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDeckItem({required String title, required String subtitle, required String imageUrl, required bool isDue}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
           ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imageUrl,
                  height: 50,
                  width: 35,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 50, width: 35, color: Colors.grey[300],
                  ),
                ),
              ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                 if (isDue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFFEBE5), borderRadius: BorderRadius.circular(4)),
                      child: Text(subtitle, style: const TextStyle(color: Color(0xFFFF5722), fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                 else
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                      child: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
