enum MessageType {
  text,
  file,
  image,
  video,
}

class ChatMessage {
  final String id;
  final String content;
  final bool isSelf;
  final DateTime timestamp;
  final MessageType type;
  final int? fileSize;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isSelf,
    required this.timestamp,
    required this.type,
    this.fileSize,
  });
}
