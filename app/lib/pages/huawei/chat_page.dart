import 'package:common/model/device.dart';
import 'package:common/model/file_type.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/pages/huawei/chat_bubble.dart';
import 'package:localsend_app/pages/huawei/chat_message.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/util/native/file_picker.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ChatPage extends StatefulWidget {
  final Device device;

  const ChatPage({super.key, required this.device});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _showFilePicker = true;

  @override
  void initState() {
    super.initState();
    _showFilePicker = true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        isSelf: true,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
      _showFilePicker = false;
    });

    _messageController.clear();
    _scrollToBottom();

    _startFileTransfer(text);
  }

  Future<void> _startFileTransfer([String? message]) async {
    final ip = widget.device.ip;
    if (ip == null) return;

    List<CrossFile> files = [];

    if (message != null && message.isNotEmpty) {
      files = [
        CrossFile(
          name: 'message.txt',
          size: message.length,
          fileType: FileType.text,
          thumbnail: null,
          asset: null,
          path: null,
          bytes: message.codeUnits,
          lastModified: null,
          lastAccessed: null,
        ),
      ];
    }

    await context.ref.notifier(sendProvider).startSession(
      target: widget.device,
      files: files,
      background: false,
    );
  }

  Future<void> _pickAndSendFile(FilePickerOption option) async {
    final ref = context.ref;

    await ref.global.dispatchAsync(PickFileAction(
      option: option,
      context: context,
    ));

    if (!mounted) return;

    final selectedFiles = ref.read(selectedSendingFilesProvider);
    if (selectedFiles.isEmpty) return;

    for (final file in selectedFiles) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: file.name,
          isSelf: true,
          timestamp: DateTime.now(),
          type: _getMessageType(file.fileType),
          fileSize: file.size,
        ));
      });
    }
    _scrollToBottom();

    await ref.notifier(sendProvider).startSession(
      target: widget.device,
      files: selectedFiles.toList(),
      background: false,
    );

    ref.redux(selectedSendingFilesProvider).dispatch(ClearSelectionAction());
  }

  MessageType _getMessageType(FileType type) {
    switch (type) {
      case FileType.image:
        return MessageType.image;
      case FileType.video:
        return MessageType.video;
      default:
        return MessageType.file;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.device.alias,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.device.deviceModel ?? '',
              style: TextStyle(
                fontSize: 11,
                color: HuaweiColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          _buildInputArea(),
          if (_showFilePicker) _buildFilePicker(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.share_rounded,
            size: 72,
            color: HuaweiColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '向 ${widget.device.alias} 发送文件',
            style: TextStyle(
              color: HuaweiColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '选择下方文件类型开始传输',
            style: TextStyle(
              color: HuaweiColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _showFilePicker ? Icons.keyboard : Icons.add_circle_outline,
              color: HuaweiColors.primary,
            ),
            onPressed: () {
              setState(() {
                _showFilePicker = !_showFilePicker;
              });
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: HuaweiColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '选择文件',
                style: TextStyle(
                  color: HuaweiColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPickerButton(
                icon: Icons.photo_outlined,
                label: '图片',
                color: HuaweiColors.primary,
                onTap: () => _pickAndSendFile(FilePickerOption.media),
              ),
              _buildPickerButton(
                icon: Icons.insert_drive_file_outlined,
                label: '文件',
                color: Colors.orange,
                onTap: () => _pickAndSendFile(FilePickerOption.file),
              ),
              _buildPickerButton(
                icon: Icons.folder_outlined,
                label: '文件夹',
                color: HuaweiColors.success,
                onTap: () => _pickAndSendFile(FilePickerOption.folder),
              ),
              _buildPickerButton(
                icon: Icons.text_snippet_outlined,
                label: '文本',
                color: Colors.purple,
                onTap: () => _pickAndSendFile(FilePickerOption.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: HuaweiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
