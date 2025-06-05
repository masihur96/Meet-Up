import 'package:meet_check/model/user_model.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String messageId;
  final String status; // 'sent', 'delivered', 'read'
  final String type; // 'text', 'image', 'video', etc. (optional, can be added later)
  final String? fileName; // Optional field for image URL
  final bool isPinned;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.messageId,
    this.status = 'sent',
    this.type = 'text', // Default type is 'text'
    this.fileName = '', // Default type is 'text'
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'messageId': messageId,
      'status': status,
      'type': type, // Include type in the map
      'fileName': fileName, // Include type in the map
      'isPinned': isPinned,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'messageId': messageId,
      'status': status,
      'type': type,
      'isPinned': isPinned,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      messageId: map['messageId'],
      status: map['status'] ?? 'sent',
      type: map['type'] ?? 'text', // Default to 'text' if not provided
      fileName: map['fileName'] ?? '', // Default to 'text' if not provided
      isPinned: map['isPinned'] ?? false,
    );
  }

  factory MessageModel.fromJson(Map<dynamic, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      messageId: json['messageId'],
      status: json['status'],
      type: json['type'],
      isPinned: json['isPinned'] ?? false,
    );
  }
}




class MessageModelWithSender {
  final UserModel sender; // Unique identifier for the message
  final MessageModel message;

  MessageModelWithSender({
    required this.sender,
    required this.message,
  });
}