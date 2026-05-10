import 'package:flutter/material.dart';
import 'package:localsend_app/config/wechat_theme.dart';
import 'package:localsend_app/pages/wechat/chat_page.dart';
import 'package:localsend_app/util/file_size_helper.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isSelf)
            CircleAvatar(
              backgroundColor: WeChatColors.primary,
              radius: 16,
              child: const Icon(Icons.devices, color: Colors.white, size: 16),
            ),
          if (!message.isSelf) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: message.isSelf ? WeChatColors.chatBubbleSelf : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.text)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: message.isSelf ? Colors.white : Colors.black87,
                      ),
                    )
                  else if (message.type == MessageType.file)
                    _buildFileMessage(message.isSelf)
                  else if (message.type == MessageType.image)
                    Image.network(
                      message.content,
                      width: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isSelf ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isSelf) const SizedBox(width: 8),
          if (message.isSelf)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
              child: const Icon(Icons.person, color: Colors.grey, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(bool isSelf) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.insert_drive_file,
          color: isSelf ? Colors.white : WeChatColors.primary,
          size: 32,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isSelf ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (message.fileSize != null)
                Text(
                  message.fileSize!.asReadableFileSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelf ? Colors.white70 : Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
