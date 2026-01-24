import 'package:flutter/material.dart';

class ReadingScreen extends StatelessWidget {
  final String bookTitle;

  const ReadingScreen({super.key, required this.bookTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm paper-like color
      appBar: AppBar(
        title: Text(bookTitle, style: const TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          '''
Chương 1: Khởi đầu mới

Cậu bé tên là Santiago. Trời đã bắt đầu tối khi cậu đến một ngôi nhà thờ cổ bỏ hoang. Mái nhà đã sập từ lâu và ở nơi xưa kia là phòng thay áo lễ nay sừng sững một cây dâu tằm to lớn.

Cậu quyết định ngủ lại đó. Cậu lùa bầy cừu qua khung cửa đã hư hại rồi chắn lại bằng mấy thanh gỗ để chúng khỏi chạy mất trong đêm. Vùng này không có chó sói nhưng đã có đêm một con cừu chui ra ngoài khiến hôm sau cậu phải mất cả ngày đi tìm.

Cậu trải chiếc áo khoác trên nền đất, ngả lưng và dùng quyển sách đang đọc dở làm gối. Cậu tự nhủ lần sau phải tìm những quyển sách dày hơn để vừa đọc được lâu, vừa gối đầu thoải mái hơn.

Khi cậu tỉnh giấc thì trời còn tối mịt. Nhìn lên cao, cậu thấy sao trời lấp lánh qua những khoảng trống trên mái nhà.

"Mình muốn ngủ tiếp," cậu nghĩ. Cậu lại mơ giấc mơ y hệt cách đây một tuần và lần này cũng thức giấc giữa chừng.

Cậu ngồi dậy uống một ngụm rượu vang rồi dùng gậy đánh thức từng con cừu một. Cậu nhận thấy rằng hình như ngay khi cậu thức giấc, hầu như cả đàn cừu cũng thức theo. Như thể có một sự hòa điệu huyền bí giữa đời sống của bầy cừu với cuộc đời của những người chăn nuôi như cậu, những người đã lang thang cùng chúng suốt hai năm nay qua khắp các vùng quê để tìm thức ăn và nước uống.

"Chúng đã quá quen với giờ giấc của mình," cậu lẩm bẩm. Suy nghĩ một lát, cậu lại thấy có thể ngược lại lắm: rằng chính cậu đã quen với giờ giấc của chúng.

(Đây là nội dung mô phỏng để xem trước giao diện đọc sách)
          ''',
          style: const TextStyle(
            fontSize: 18,
            height: 1.6,
            fontFamily: 'Georgia', // Serif font for reading
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
