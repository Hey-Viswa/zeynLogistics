import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/services/auth_service.dart';
import 'chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId; // Typically the Driver's UID

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final text = _controller.text.trim();
    _controller.clear();

    ref
        .read(chatServiceProvider)
        .sendMessage(chatId: widget.chatId, senderId: user.uid, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Support Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ref.read(chatServiceProvider).getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  reverse: true, // Start from bottom
                  padding: EdgeInsets.all(16.w),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUser?.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                            bottomLeft: isMe
                                ? Radius.circular(12.r)
                                : Radius.zero,
                            bottomRight: isMe
                                ? Radius.zero
                                : Radius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isMe
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
