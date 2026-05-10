import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/pages/huawei/chat_message.dart';
import 'package:localsend_app/util/file_size_helper.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selfBg = HuaweiColors.primary;
    final otherBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isSelf)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: HuaweiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.devices, color: HuaweiColors.primary, size: 18),
            ),
          if (!message.isSelf) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isSelf ? selfBg : otherBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: message.isSelf
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isSelf
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: message.isSelf
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.text)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: message.isSelf ? Colors.white : HuaweiColors.textPrimary,
                        fontSize: 15,
                      ),
                    )
                  else if (message.type == MessageType.file)
                    _buildFileMessage(message.isSelf, isDark)
                  else if (message.type == MessageType.image)
                    Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: HuaweiColors.textTertiary,
                        size: 48,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isSelf ? Colors.white70 : HuaweiColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isSelf) const SizedBox(width: 8),
          if (message.isSelf)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: HuaweiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: HuaweiColors.primary, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(bool isSelf, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelf ? Colors.white.withValues(alpha: 0.2) : HuaweiColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.insert_drive_file,
            color: isSelf ? Colors.white : HuaweiColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isSelf ? Colors.white : HuaweiColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (message.fileSize != null)
                Text(
                  message.fileSize!.asReadableFileSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelf ? Colors.white70 : HuaweiColors.textTertiary,
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
