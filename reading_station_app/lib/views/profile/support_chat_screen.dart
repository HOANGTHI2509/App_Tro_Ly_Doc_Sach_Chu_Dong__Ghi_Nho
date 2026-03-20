import 'package:flutter/material.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: const Text(
          'Chat hỗ trợ',
          style: TextStyle(
            color: Color(0xFF385A46),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF4A745B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBE6DF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Hôm nay', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                  ),
                ),
                const SizedBox(height: 24),
                _buildMessageBubble(
                  isMe: false,
                  avatarColor: const Color(0xFFC8E6C9),
                  avatarIcon: Icons.support_agent_rounded,
                  text: 'Chào Oakley, tôi có thể giúp gì\ncho bạn hôm nay?',
                  time: '09:15 AM',
                ),
                const SizedBox(height: 20),
                _buildMessageBubble(
                  isMe: true,
                  avatarColor: const Color(0xFFF2DFCD),
                  avatarIcon: Icons.person_rounded,
                  text: "Chào bạn, tôi muốn hỏi về\ntrạng thái đơn hàng sách 'Cánh\nđồng bất tận' của mình.",
                  time: '09:16 AM',
                ),
                const SizedBox(height: 20),
                _buildMessageBubble(
                  isMe: false,
                  avatarColor: const Color(0xFFC8E6C9),
                  avatarIcon: Icons.support_agent_rounded,
                  text: 'Dạ vâng, để tôi kiểm tra giúp\nbạn. Đơn hàng #TD-202405\nđang trong quá trình đóng gói\nvà sẽ được giao trong 2 ngày\ntới ạ.',
                  time: '09:18 AM',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 52),
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text('Hỗ trợ đang soạn tin nhắn...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F7F2),
            ),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A745B),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE5),
                      border: Border.all(color: const Color(0xFFDBD6CA), width: 1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Nhập tin nhắn...', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        ),
                        const Icon(Icons.emoji_emotions_rounded, color: Color(0xFF4A745B)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A745B),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required Color avatarColor,
    required IconData avatarIcon,
    required String text,
    required String time,
  }) {
    Widget avatar = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
      ),
      child: Icon(avatarIcon, color: isMe ? const Color(0xFFA17F5D) : const Color(0xFF385A46), size: 18),
    );

    Widget bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF4A745B) : const Color(0xFFEBE6DF),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(24),
          topRight: const Radius.circular(24),
          bottomLeft: Radius.circular(isMe ? 24 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 24),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : const Color(0xFF1B263B),
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              avatar,
              const SizedBox(width: 12),
            ],
            Flexible(child: bubble),
            if (isMe) ...[
              const SizedBox(width: 12),
              avatar,
            ],
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: isMe ? 0 : 54, right: isMe ? 54 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              if (isMe) ...[
                const SizedBox(width: 4),
                const Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF4A745B)),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
