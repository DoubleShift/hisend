import 'dart:io';

import 'package:common/model/device.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/wechat_theme.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/pages/wechat/chat_bubble.dart';
import 'package:localsend_app/pages/wechat/select_files_page.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/util/native/file_picker.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

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
  bool _showMoreActions = false;

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
          bytes: message.codeUnits,
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
    final files = await pickFiles(
      option: option,
      context: context,
    );

    if (files == null || files.isEmpty) return;

    for (final file in files) {
      final ip = widget.device.ip;
      if (ip == null) continue;

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
      _scrollToBottom();
    }

    await context.ref.notifier(sendProvider).startSession(
      target: widget.device,
      files: files,
      background: false,
    );
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

  void _toggleMoreActions() {
    setState(() {
      _showMoreActions = !_showMoreActions;
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
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '开始和 ${widget.device.alias} 聊天',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '发送文件、图片或消息',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
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
          if (_showMoreActions) _buildMoreActions(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: WeChatColors.chatBackground,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: 6 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _showMoreActions ? Icons.keyboard : Icons.add_circle_outline,
              color: WeChatColors.primary,
            ),
            onPressed: _toggleMoreActions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              color: WeChatColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreActions() {
    return Container(
      color: WeChatColors.chatBackground,
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildActionButton(
            icon: Icons.photo,
            label: '图片',
            onTap: () => _pickAndSendFile(FilePickerOption.gallery),
          ),
          _buildActionButton(
            icon: Icons.folder,
            label: '文件',
            onTap: () => _pickAndSendFile(FilePickerOption.file),
          ),
          _buildActionButton(
            icon: Icons.video_call,
            label: '视频',
            onTap: () => _pickAndSendFile(FilePickerOption.video),
          ),
          _buildActionButton(
            icon: Icons.camera_alt,
            label: '相机',
            onTap: () => _pickAndSendFile(FilePickerOption.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: WeChatColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

enum MessageType { text, file, image, video }

class ChatMessage {
  final String id;
  final String content;
  final bool isSelf;
  final DateTime timestamp;
  final MessageType type;
  final int? fileSize;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isSelf,
    required this.timestamp,
    required this.type,
    this.fileSize,
  });
}
