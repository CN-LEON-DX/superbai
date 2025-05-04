class ChatMessage {
  final String? id;
  final String chatId;
  final String senderId;
  final String message;
  final String messageType;
  final String? audioUrl;
  final String? fileUrl;
  final DateTime createdAt;
  final bool isMe;
  final String senderName;

  ChatMessage({
    this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.messageType,
    this.audioUrl,
    this.fileUrl,
    required this.createdAt,
    required this.isMe,
    required this.senderName,
  });

  // Create a message from a map (database response)
  factory ChatMessage.fromMap(Map<String, dynamic> map, String currentUserId) {
    return ChatMessage(
      id: map['id']?.toString(),
      chatId: map['chat_id'],
      senderId: map['sender_id'],
      message: map['message'],
      messageType: map['message_type'] ?? 'text',
      audioUrl: map['audio_url'],
      fileUrl: map['file_url'],
      createdAt: DateTime.parse(map['created_at']),
      isMe: map['is_from_user'] ?? (map['sender_id'] == currentUserId),
      senderName: map['sender_name'] ?? (map['sender_id'] == currentUserId ? 'You' : 'AI Assistant'),
    );
  }

  // Create a local message before server confirmation
  static ChatMessage createLocalMessage(
    String chatId,
    String senderId,
    String messageText, {
    String messageType = 'text',
    String? senderName,
  }) {
    return ChatMessage(
      chatId: chatId,
      senderId: senderId,
      message: messageText,
      messageType: messageType,
      createdAt: DateTime.now(),
      isMe: true,
      senderName: senderName ?? 'You',
    );
  }

  // Convert message to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'message_type': messageType,
      'audio_url': audioUrl,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'is_me': isMe,
      'sender_name': senderName,
    };
  }
} 