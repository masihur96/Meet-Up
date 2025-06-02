import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meet_check/model/message_model.dart';
import 'package:meet_check/model/user_model.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  final UserModel currentUser;

  const ChatScreen({
    Key? key,
    required this.receiver,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> messages = [];
  bool isTyping = false;
  Timer? _typingTimer;
  bool isReceiverOnline = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupTypingListener();
    _setupOnlineStatus();
    _markMessagesAsRead();
  }

  void _setupOnlineStatus() {
    _database.child('users/${widget.receiver.id}/status').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          isReceiverOnline = event.snapshot.value == 'online';
        });
      }
    });
  }

  void _setupTypingListener() {
    String chatId = _getChatId();
    _database.child('chats/$chatId/typing/${widget.receiver.id}').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          isTyping = event.snapshot.value as bool;
        });
      }
    });
  }

  void _markMessagesAsRead() {
    String chatId = _getChatId();
    _database.child('chats/$chatId/messages').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final message = MessageModel.fromMap(Map<String, dynamic>.from(value));
          if (message.receiverId == widget.currentUser.id && message.status != 'read') {
            _database.child('chats/$chatId/messages/$key/status').set('read');
          }
        });
      }
    });
  }

  void _updateTypingStatus(bool isTyping) {
    String chatId = _getChatId();
    _database.child('chats/$chatId/typing/${widget.currentUser.id}').set(isTyping);
  }

  void _onTypingChanged(String text) {
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();
    
    _updateTypingStatus(true);
    
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _updateTypingStatus(false);
    });
  }

  void _loadMessages() {
    String chatId = _getChatId();
    _database.child('chats/$chatId/messages').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final messagesList = data.entries.map((entry) {
          return MessageModel.fromMap(Map<String, dynamic>.from(entry.value));
        }).toList();

        messagesList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          messages = messagesList;
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  String _getChatId() {
    // Create a unique chat ID by sorting user IDs
    List<String> ids = [widget.currentUser.id, widget.receiver.id];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String chatId = _getChatId();
    String messageId = DateTime.now().millisecondsSinceEpoch.toString();

    MessageModel message = MessageModel(
      senderId: widget.currentUser.id,
      receiverId: widget.receiver.id,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
      messageId: messageId,
    );

    await _database.child('chats/$chatId/messages/$messageId').set(message.toMap());
    _messageController.clear();
    _updateTypingStatus(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.receiver.avatarUrl),
                ),
                if (isReceiverOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiver.name),
                if (isTyping)
                  const Text(
                    'typing...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == widget.currentUser.id;

                return Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        message.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (isMe)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          message.status,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: _onTypingChanged,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _updateTypingStatus(false);
    super.dispose();
  }
}