import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:meet_check/model/message_model.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:meet_check/screens/custom_size.dart';
import 'package:meet_check/service/fcm_service.dart';



class MessagingHomePage extends StatefulWidget {


  const MessagingHomePage({super.key});

  @override
  State<MessagingHomePage> createState() => _MessagingHomePageState();
}

class _MessagingHomePageState extends State<MessagingHomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FCMService _firebaseService = FCMService();
  List<MessageModelWithSender> pinnedChats = [];
  List<MessageModelWithSender> recentChats = [];
  StreamSubscription<DatabaseEvent>? _usersSubscription;
  List<UserModel> allUsers = [];
  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenToAllUsers();
  }

  void _listenToAllUsers() {
    _usersSubscription = _database.child('users').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final usersMap = Map<String, dynamic>.from(data as Map);
        final usersList = usersMap.entries.map((entry) {
          final userMap = Map<String, dynamic>.from(entry.value);
          return UserModel.fromMap(userMap);
        }).toList();

        setState(() {
          allUsers = usersList;
        });
      }
    });
  }

  void _loadMessages() {
    // Listen to messages
    _firebaseService.getMessages('currentUserId').listen((messages) {
      setState(() {
        pinnedChats = messages.where((m) => m.message.isPinned).toList();
        recentChats = messages.where((m) => !m.message.isPinned).toList();
      });
    });
  }

  // Add this method to handle sending messages
  Future<void> _sendMessage(String message) async {
    final newMessage = MessageModel(
      senderId: 'currentUserId',
      receiverId: 'receiverId',
      message: message,
      timestamp: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      status: 'sent',
      type: 'text',
    );

    await _firebaseService.sendMessage(newMessage);
  }

  // Add this method to handle pinning/unpinning
  Future<void> _togglePin(MessageModelWithSender chat) async {
    await _firebaseService.togglePinChat(
      chat.message.messageId,
      !chat.message.isPinned,
    );
  }


  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Messages", style: TextStyle(color: Colors.black)),
        actions: const [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 16),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "    Track messages from one place",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pinned Chats",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: GridView.builder(
                shrinkWrap: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.7, // ✅ width / height ratio (try 2.5 for rectangle)
                ),

                itemCount: pinnedChats.length, // your data list
                itemBuilder: (context, index) {
                  final chat = pinnedChats[index];
                  return pinnedChatTile(
                    context,
                    chat,
                    unread: chat.message.status == 'sent', // Example condition for unread
                  );
                },
              ),

            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Recent Chats",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
             chatTabBar(context),
             Expanded(
              child: chatList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff7c3aed),
        onPressed: () {},
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget pinnedChatTile(BuildContext context,  MessageModelWithSender chat, {bool unread = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xffede9fe), Color(0xfff3e8ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child:Stack(
        // ✅ Don't expand — allow content to decide height
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ auto height
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(chat.sender.avatarUrl ?? "assets/images/user.png"),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chat.sender.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),

                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                chat.message.message,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (unread)
            const Positioned(
              right: 0,
              top: 0,
              child: Icon(Icons.circle, size: 14, color: Color(0xff7c3aed)),
            ),
        ],
      )

    );
  }

  Widget chatTabBar (BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            tabChip(label: "All chats", selected: true),
            SizedBox(width: 8),
            tabChip(label: "Personal"),
            SizedBox(width: 8),
            tabChip(label: "Work"),
            SizedBox(width: 8),
            tabChip(label: "Groups"),
          ],
        ),
      ),
    );
  }

  Widget tabChip( {required String label,bool selected = false}) {
    return Chip(
      label: Text(label),
      backgroundColor: selected ? const Color(0xff7c3aed) : Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget chatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        final user = allUsers[index];
        return ChatTile(
          name: user.name,
          message: "Pls take a look at the images.",
          time: "18.31",
          unreadCount: 5,
          imagePath: user.avatarUrl ,
        );
      },
    );
  }

}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final String imagePath;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.unreadCount = 0,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(backgroundImage: NetworkImage(imagePath)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(fontSize: 12)),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff7c3aed),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
