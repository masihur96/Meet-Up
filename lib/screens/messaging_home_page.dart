// import 'package:flutter/material.dart';
// import 'package:meet_check/screens/custom_size.dart';
//
// class MessagingHomePage extends StatelessWidget {
//
//
//   const MessagingHomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff2f2f7),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text("Messages", style: TextStyle(color: Colors.black)),
//         actions: const [
//           Icon(Icons.search, color: Colors.black),
//           SizedBox(width: 16),
//           Icon(Icons.settings, color: Colors.black),
//           SizedBox(width: 16),
//         ],
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(24),
//           child: Padding(
//             padding: EdgeInsets.only(bottom: 8.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "    Track messages from one place",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Pinned Chats",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(
//               height: 200,
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 children: [
//                   pinnedChatTile("Mike Wazowski", "That's awesome! ..", "assets/images/user.png"),
//                   pinnedChatTile("Darlene Steward", "Pls take a look at the..", "assets/images/user.png", unread: true),
//                   pinnedChatTile("Gregory Robertson", "Preparing for next vac..", "assets/images/user.png"),
//                   pinnedChatTile("Dwight Wilson", "I'd like to watch ...", "assets/images/user.png"),
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 "Recent Chats",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const ChatTabBar(),
//             const Expanded(
//               child: ChatList(),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xff7c3aed),
//         onPressed: () {},
//         child: const Icon(Icons.message),
//       ),
//     );
//   }
//
//   Widget pinnedChatTile(String name, String message, String imagePath, {bool unread = false}) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           colors: [Color(0xffede9fe), Color(0xfff3e8ff)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       padding: const EdgeInsets.all(8),
//       child: Stack(
//         children: [
//           Column(
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(backgroundImage: AssetImage(imagePath)),
//                   const SizedBox(width: 8),
//                   SizedBox(
//                    width: screenSize(context, .1),
//
//                       child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
//
//                 ],
//               ),
//               Text(message, style: const TextStyle(fontSize: 11, color: Colors.black54), overflow: TextOverflow.ellipsis),
//
//             ],
//           ),
//
//           Positioned(right: 8,
//             top: 8,child:  unread?
//     const Icon(Icons.circle, size: 8, color: Color(0xff7c3aed)) : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ChatTabBar extends StatelessWidget {
//   const ChatTabBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TabChip(label: "All chats", selected: true),
//           TabChip(label: "Personal"),
//           TabChip(label: "Work"),
//           TabChip(label: "Groups"),
//         ],
//       ),
//     );
//   }
// }
//
// class TabChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//
//   const TabChip({super.key, required this.label, this.selected = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       label: Text(label),
//       backgroundColor: selected ? const Color(0xff7c3aed) : Colors.grey[200],
//       labelStyle: TextStyle(
//         color: selected ? Colors.white : Colors.black,
//       ),
//     );
//   }
// }
//
// class ChatList extends StatelessWidget {
//   const ChatList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       children: const [
//         ChatTile(
//           name: "Darlene Steward",
//           message: "Pls take a look at the images.",
//           time: "18.31",
//           unreadCount: 5,
//           imagePath: "assets/images/user.png",
//         ),
//         ChatTile(
//           name: "Fullsnack Designers",
//           message: "Hello guys, we have discussed about ...",
//           time: "16.04",
//           imagePath: "assets/images/user.png",
//         ),
//         ChatTile(
//           name: "Lee Williamson",
//           message: "Yes, that's gonna work, hopefully.",
//           time: "06.12",
//           imagePath: "assets/images/user.png",
//         ),
//         ChatTile(
//           name: "Ronald Mccoy",
//           message: "Thanks dude 😎",
//           time: "Yesterday",
//           imagePath: "assets/images/user.png",
//         ),
//       ],
//     );
//   }
// }
//
// class ChatTile extends StatelessWidget {
//   final String name;
//   final String message;
//   final String time;
//   final int unreadCount;
//   final String imagePath;
//
//   const ChatTile({
//     super.key,
//     required this.name,
//     required this.message,
//     required this.time,
//     this.unreadCount = 0,
//     required this.imagePath,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(vertical: 8),
//       leading: CircleAvatar(backgroundImage: AssetImage(imagePath)),
//       title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//       subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
//       trailing: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(time, style: const TextStyle(fontSize: 12)),
//           if (unreadCount > 0)
//             Container(
//               margin: const EdgeInsets.only(top: 4),
//               padding: const EdgeInsets.all(6),
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xff7c3aed),
//               ),
//               child: Text(
//                 unreadCount.toString(),
//                 style: const TextStyle(fontSize: 10, color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
