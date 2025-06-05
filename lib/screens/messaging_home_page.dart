import 'package:flutter/material.dart';
import 'package:meet_check/model/message_model.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:meet_check/screens/custom_size.dart';


class MessagingHomePage extends StatefulWidget {


  const MessagingHomePage({super.key});

  @override
  State<MessagingHomePage> createState() => _MessagingHomePageState();
}

class _MessagingHomePageState extends State<MessagingHomePage> {
  final List<MessageModelWithSender> pinnedChats = [


    MessageModelWithSender(
      sender: UserModel(id: "01", name: "Masihur Rohman", avatarUrl: "assets/images/user.png",token: "token_01" ),
      message: MessageModel(
        senderId: 'Masihur Rohman',
        receiverId: 'user_2',
        message: "That's awesome! ..",
        timestamp: DateTime.now(),
        messageId: 'msg_001',
        status: 'sent',
        type: 'text',
      ),

    ),
    MessageModelWithSender(
      sender: UserModel(id: "01", name: "Masihur Rohman", avatarUrl: "assets/images/user.png",token: "token_01" ),
      message: MessageModel(
        senderId: 'Masihur Rohman',
        receiverId: 'user_2',
        message: "That's awesome! ..",
        timestamp: DateTime.now(),
        messageId: 'msg_001',
        status: 'sent',
        type: 'text',
      ),

    ),
    MessageModelWithSender(
      sender: UserModel(id: "01", name: "Masihur Rohman", avatarUrl: "assets/images/user.png",token: "token_01" ),
      message: MessageModel(
        senderId: 'Masihur Rohman',
        receiverId: 'user_2',
        message: "That's awesome! ..",
        timestamp: DateTime.now(),
        messageId: 'msg_001',
        status: 'sent',
        type: 'text',
      ),

    ),
    MessageModelWithSender(
      sender: UserModel(id: "01", name: "Masihur Rohman", avatarUrl: "assets/images/user.png",token: "token_01" ),
      message: MessageModel(
        senderId: 'Masihur Rohman',
        receiverId: 'user_2',
        message: "That's awesome! ..",
        timestamp: DateTime.now(),
        messageId: 'msg_001',
        status: 'sent',
        type: 'text',
      ),

    ),
    MessageModelWithSender(
      sender: UserModel(id: "01", name: "Masihur Rohman", avatarUrl: "assets/images/user.png",token: "token_01" ),
      message: MessageModel(
        senderId: 'Masihur Rohman',
        receiverId: 'user_2',
        message: "That's awesome! ..",
        timestamp: DateTime.now(),
        messageId: 'msg_001',
        status: 'sent',
        type: 'text',
      ),

    ),
    MessageModelWithSender(
      sender: UserModel(id: "01", name: "Masihur Rohman", avatarUrl: "assets/images/user.png",token: "token_01" ),
      message: MessageModel(
        senderId: 'Masihur Rohman',
        receiverId: 'user_2',
        message: "That's awesome! ..",
        timestamp: DateTime.now(),
        messageId: 'msg_001',
        status: 'sent',
        type: 'text',
      ),

    ),
    MessageModelWithSender(
      sender: UserModel(id: "01", name: "Masihur Rohman", avatarUrl: "assets/images/user.png",token: "token_01" ),
      message: MessageModel(
        senderId: 'Masihur Rohman',
        receiverId: 'user_2',
        message: "That's awesome! ..",
        timestamp: DateTime.now(),
        messageId: 'msg_001',
        status: 'sent',
        type: 'text',
      ),

    )



   ];

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
            const ChatTabBar(),
            const Expanded(
              child: ChatList(),
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
        // ✅ Don’t expand — allow content to decide height
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
}

class ChatTabBar extends StatelessWidget {
  const ChatTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TabChip(label: "All chats", selected: true),
            const SizedBox(width: 8),
            TabChip(label: "Personal"),
            const SizedBox(width: 8),
            TabChip(label: "Work"),
            const SizedBox(width: 8),
            TabChip(label: "Groups"),
          ],
        ),
      ),
    );
  }
}

class TabChip extends StatelessWidget {
  final String label;
  final bool selected;

  const TabChip({super.key, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: selected ? const Color(0xff7c3aed) : Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        ChatTile(
          name: "Darlene Steward",
          message: "Pls take a look at the images.",
          time: "18.31",
          unreadCount: 5,
          imagePath: "assets/images/user.png",
        ),
        ChatTile(
          name: "Fullsnack Designers",
          message: "Hello guys, we have discussed about ...",
          time: "16.04",
          imagePath: "assets/images/user.png",
        ),
        ChatTile(
          name: "Lee Williamson",
          message: "Yes, that's gonna work, hopefully.",
          time: "06.12",
          imagePath: "assets/images/user.png",
        ),
        ChatTile(
          name: "Ronald Mccoy",
          message: "Thanks dude 😎",
          time: "Yesterday",
          imagePath: "assets/images/user.png",
        ),
      ],
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
      leading: CircleAvatar(backgroundImage: AssetImage(imagePath)),
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
