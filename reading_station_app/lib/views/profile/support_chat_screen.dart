import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final user = Supabase.instance.client.auth.currentUser;
  late Stream<List<Map<String, dynamic>>> _messagesStream;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _messagesStream = Supabase.instance.client
          .from('support_messages')
          .stream(primaryKey: ['id'])
          .eq('user_id', user!.id)
          .order('created_at', ascending: true);
    } else {
      _messagesStream = Stream.value([]);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || user == null) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      await Supabase.instance.client.from('support_messages').insert({
        'user_id': user!.id,
        'message': text,
        'is_from_user': true,
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi tin nhắn: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(dateTime); // e.g. 09:15 AM
    } catch (e) {
      return '';
    }
  }

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
        backgroundColor: const Color(0xFFF9F7F2), // same as bg
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF4A745B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Thời gian làm việc của hỗ trợ viên: 8:00 - 17:00 (Thứ 2 - Thứ 6)',
                  ),
                  backgroundColor: Color(0xFF4A745B),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Đã xảy ra lỗi khi tải tin nhắn.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A745B)),
                  );
                }

                final messages = snapshot.data ?? [];

                // Cuộn xuống để xem tn mới nhất khi load xong
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length + 1, // +1 cho lời chào ban đầu
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBE6DF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Bắt đầu hội thoại',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildMessageBubble(
                            isMe: false,
                            avatarColor: const Color(0xFFC8E6C9),
                            avatarIcon: Icons.support_agent_rounded,
                            text:
                                'Chào bạn, tôi là trợ lý từ Trạm Đọc. Bạn cần chúng tôi hỗ trợ vấn đề gì ạ?',
                            time: 'Bây giờ',
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }

                    final msg =
                        messages[index - 1]; // -1 vì index 0 là lời chào
                    final isFromUser = msg['is_from_user'] as bool? ?? true;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildMessageBubble(
                        isMe: isFromUser,
                        avatarColor: isFromUser
                            ? const Color(0xFFF2DFCD)
                            : const Color(0xFFC8E6C9),
                        avatarIcon: isFromUser
                            ? Icons.person_rounded
                            : Icons.support_agent_rounded,
                        text: msg['message'] ?? '',
                        time: _formatTime(msg['created_at']),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(color: Color(0xFFF9F7F2)),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFECE5),
                      border: Border.all(
                        color: const Color(0xFFDBD6CA),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: const Icon(
                          Icons.emoji_emotions_rounded,
                          color: Color(0xFF4A745B),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _isSending ? Colors.grey : const Color(0xFF4A745B),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    onPressed: _isSending ? null : _sendMessage,
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
      decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
      child: Icon(
        avatarIcon,
        color: isMe ? const Color(0xFFA17F5D) : const Color(0xFF385A46),
        size: 18,
      ),
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
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[avatar, const SizedBox(width: 12)],
            Flexible(child: bubble),
            if (isMe) ...[const SizedBox(width: 12), avatar],
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: isMe ? 0 : 54, right: isMe ? 54 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.done_all_rounded,
                  size: 14,
                  color: Color(0xFF4A745B),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
