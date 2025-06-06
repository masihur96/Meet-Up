import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:meet_check/model/message_model.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:meet_check/screens/custom_size.dart';
import 'package:meet_check/service/fcm_service.dart';

import '../service/local_storage_service.dart';
import 'chat_screen.dart';
import 'new_group_screen.dart';

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

  UserModel? _currentUser;
  List<UserModel> pinnedUsers = [];

  @override
  void initState() {
    super.initState();

    _listenToAllUsers();
  }

  void _listenToAllUsers() async {
    UserModel? userModel = await LocalUserStorage.getUser();
    if (userModel == null) {
      return;
    }
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
        getUserById(userModel.id, allUsers);
      }
    });
  }

  getUserById(String id, List<UserModel> allUsers) async {
    if (allUsers.isEmpty) {
      return;
    }
    try {
      setState(() {
        _currentUser = allUsers.firstWhere((user) => user.id == id,
            orElse: () => UserModel(id: '', name: ''));
        pinnedUsers = getPinnedUsers(_currentUser!.pinnedUserIds, allUsers);
      });
    } catch (e) {
      return null;
    }
  }

  List<UserModel> getPinnedUsers(
      List<String> pinnedUserIds, List<UserModel> allUsers) {
    return allUsers.where((user) => pinnedUserIds.contains(user.id)).toList();
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: Colors.black),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.black),
            onSelected: (value) {
              // Handle menu selection
              if (value == 'new_group') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewGroupScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'new_group',
                child: Text('New Group'),
              ),
            ],
          ),
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
            pinnedUsers.isEmpty
                ? SizedBox()
                : Text(
                    "Pinned Chats",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            pinnedUsers.isEmpty
                ? SizedBox()
                : SizedBox(
                    height: pinnedUsers.length < 2 ? 100 : 200,
                    child: GridView.builder(
                      shrinkWrap: false,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            1.7, // ✅ width / height ratio (try 2.5 for rectangle)
                      ),

                      itemCount: pinnedUsers.length,
                      // your data list
                      itemBuilder: (context, index) {
                        final chat = pinnedUsers[index];
                        return pinnedChatTile(
                          context,
                          chat, // Example condition for unread
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
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget pinnedChatTile(
    BuildContext context,
    UserModel user,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to chat screen with user details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              receiver: user,
              currentUser: _currentUser ?? UserModel(id: '', name: ''),
            ),
          ),
        );
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xffede9fe), Color(0xfff3e8ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Stack(
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
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.name,
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
                    user.lastMessage,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (user.unseenMessageCount > 0)
                Positioned(
                  right: 0,
                  top: -5,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff7c3aed),
                    ),
                    child: Text(
                      user.unseenMessageCount.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  Widget chatTabBar(BuildContext context) {
    return Padding(
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

  Widget tabChip({required String label, bool selected = false}) {
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
          currentUser: _currentUser ?? UserModel(id: '', name: ''),
          user: user,
        );
      },
    );
  }
}

class ChatTile extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;

  const ChatTile({
    super.key,
    required this.user,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigate to chat screen with user details
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChatScreen(
                      receiver: user,
                      currentUser: currentUser,
                    )));
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
      title:
          Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          Text(user.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(user.lastMessageTime, style: const TextStyle(fontSize: 12)),
          if (user.unseenMessageCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff7c3aed),
              ),
              child: Text(
                user.unseenMessageCount.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
