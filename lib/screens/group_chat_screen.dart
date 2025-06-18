// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import '../model/group_model.dart';
// import '../model/message_model.dart';
// import '../model/user_model.dart';
// import 'package:record/record.dart';
//
// import 'package:video_player/video_player.dart';
//
// class GroupChatScreen extends StatefulWidget {
//   final GroupModel group;
//   final UserModel currentUser;
//
//   const GroupChatScreen({
//     super.key,
//     required this.group,
//     required this.currentUser,
//   });
//
//   @override
//   State<GroupChatScreen> createState() => _GroupChatScreenState();
// }
//
// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   final TextEditingController _messageController = TextEditingController();
//   List<MessageModelWithSender> messages = [];
//   bool _isRecording = false;
//   String? _recordingPath;
//   final _audioRecorder = Record();
//
//   @override
//   void initState() {
//     super.initState();
//     _listenToMessages();
//   }
//
//   void _listenToMessages() {
//     _database.child('group_messages').child(widget.group.id).onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         final data = Map<String, dynamic>.from(event.snapshot.value as Map);
//         final messageList = data.entries.map((entry) {
//           final messageData = Map<String, dynamic>.from(entry.value);
//           final message = MessageModel.fromMap(messageData);
//           final sender = widget.group.members.firstWhere(
//                 (user) => user.id == message.senderId,
//             orElse: () => UserModel(id: message.senderId, name: 'Unknown'),
//           );
//           return MessageModelWithSender(sender: sender, message: message);
//         }).toList()
//           ..sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
//
//         setState(() {
//           messages = messageList;
//         });
//       }
//     });
//   }
//
//   Future<void> _startRecording() async {
//     if (await _audioRecorder.hasPermission()) {
//       await _audioRecorder.start();
//       setState(() => _isRecording = true);
//     }
//   }
//
//   Future<void> _stopRecording() async {
//     _recordingPath = await _audioRecorder.stop();
//     setState(() => _isRecording = false);
//     if (_recordingPath != null) _sendAudioMessage(_recordingPath!);
//   }
//
//   Future<void> _sendAudioMessage(String path) async {
//     final message = MessageModel(
//       receiverId: widget.group.id,
//       messageId: DateTime.now().millisecondsSinceEpoch.toString(),
//       senderId: widget.currentUser.id,
//       message:   path,
//       timestamp: DateTime.now(),
//       isPinned: false,
//       type: 'audio',
//
//     );
//
//     await _database
//         .child('group_messages')
//         .child(widget.group.id)
//         .child(message.messageId)
//         .set(message.toMap());
//   }
//
//   Future<void> _pickAndSendVideo() async {
//     final picker = ImagePicker();
//     final video = await picker.pickVideo(source: ImageSource.gallery);
//     if (video != null) {
//       final message = MessageModel(
//         receiverId: widget.group.id,
//         messageId: DateTime.now().millisecondsSinceEpoch.toString(),
//         senderId: widget.currentUser.id,
//         message: widget.,
//         timestamp: DateTime.now(),
//         isPinned: false,
//         type: 'video',
//         mediaUrl: video.path, // Replace with actual uploaded URL
//       );
//
//       await _database
//           .child('group_messages')
//           .child(widget.group.id)
//           .child(message.messageId)
//           .set(message.toMap());
//     }
//   }
//
//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;
//
//     final message = MessageModel(
//       receiverId: widget.group.id,
//       messageId: DateTime.now().millisecondsSinceEpoch.toString(),
//       senderId: widget.currentUser.id,
//       message: _messageController.text.trim(),
//       timestamp: DateTime.now(),
//       isPinned: false,
//       type: 'text',
//     );
//
//     await _database
//         .child('group_messages')
//         .child(widget.group.id)
//         .child(message.messageId)
//         .set(message.toMap());
//
//     _messageController.clear();
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.group.name),
//             Text('${widget.group.members.length} members', style: const TextStyle(fontSize: 12)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () => showModalBottomSheet(
//               context: context,
//               builder: (context) => GroupInfoSheet(group: widget.group),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final msg = messages[index];
//                 final isMe = msg.message.senderId == widget.currentUser.id;
//                 return MessageBubble(message: msg, isMe: isMe);
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: () => showModalBottomSheet(
//                     context: context,
//                     builder: (context) => Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ListTile(
//                           leading: const Icon(Icons.video_library),
//                           title: const Text('Send Video'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickAndSendVideo();
//                           },
//                         ),
//                         // You can add more attachment options
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
//                   ),
//                 ),
//                 GestureDetector(
//                   onLongPress: _startRecording,
//                   onLongPressEnd: (_) => _stopRecording(),
//                   child: IconButton(
//                     icon: Icon(_isRecording ? Icons.mic : Icons.mic_none),
//                     onPressed: null,
//                   ),
//                 ),
//                 IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MessageBubble extends StatelessWidget {
//   final MessageModelWithSender message;
//   final bool isMe;
//
//   const MessageBubble({super.key, required this.message, required this.isMe});
//
//   @override
//   Widget build(BuildContext context) {
//     final msg = message.message;
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isMe ? const Color(0xff7c3aed) : Colors.grey[200],
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!isMe)
//               Text(message.sender.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//             if (msg.type == 'text')
//               Text(msg.message, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
//             if (msg.type == 'audio')
//               AudioMessageWidget(audioUrl: msg.message ?? ''),
//             if (msg.type == 'video')
//               VideoMessageWidget(videoUrl: msg.message ?? ''),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class GroupInfoSheet extends StatelessWidget {
//   final GroupModel group;
//
//   const GroupInfoSheet({super.key, required this.group});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(group.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text('Purpose: ${group.purpose}', style: const TextStyle(fontSize: 16)),
//           const SizedBox(height: 16),
//           const Text('Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           ...group.members.map((member) => Text(member)),
//         ],
//       ),
//     );
//   }
// }
//
// class AudioMessageWidget extends StatelessWidget {
//   final String audioUrl;
//
//   const AudioMessageWidget({super.key, required this.audioUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.play_arrow),
//           onPressed: () {
//             // Add audio playback implementation
//           },
//         ),
//         const Text('Audio Message'),
//       ],
//     );
//   }
// }
//
// class VideoMessageWidget extends StatelessWidget {
//   final String videoUrl;
//
//   const VideoMessageWidget({super.key, required this.videoUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => Scaffold(
//               appBar: AppBar(),
//               body: Center(
//                   child: VideoPlayer(VideoPlayerController.network(videoUrl))
//               ),
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: 200,
//         height: 150,
//         decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
//         child: const Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 50)),
//       ),
//     );
//   }
// }
