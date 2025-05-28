import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meet_check/service/call_service.dart';
import 'package:meet_check/service/fcm_service.dart';
import 'package:meet_check/service/local_storage_service.dart';


import 'meeting/join_meeting_screen.dart';
import 'model/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final CallService _callService = CallService();
  StreamSubscription<DatabaseEvent>? _usersSubscription;

  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _listenToAllUsers();
    getUser();
  }



  UserModel ? userModel;

  getUser()async{
    userModel =  await LocalUserStorage.getUser();
    setState(() {

    });

    print(userModel?.name??"Empty");
  }



  List<UserModel> allUsers = [];

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

  void _makeCall(UserModel user) async {
    // var uuid = Uuid();

    FCMService fcmService = FCMService();

    fcmService.sendNotification(
      recipientToken: user.token,
      caller: userModel!,
    );

   // fcmService.notifyPortal(receiverUid: user.id, sanderId: userModel!.id, uid: uuid.v4(), message: "Calling", title: "Calling", path: "/message");

    // Here you would typically make an API call to your backend
    // to initiate the call and notify the receiver
    // For demonstration, we'll just show the incoming call UI
    // await _callService.showIncomingCall(
    //   callerName: user.name,
    //   callerId: user.id,
    //   meetingId: user.id
    // );

  }


  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {

             // LocalUserStorage.clearUser();
              getUser();
              // await _auth.signOut();
              // Navigate to login screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:  Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  final user = allUsers[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(user.avatarUrl),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "ID: ${user.id.split("-").last}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                user.status,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.message),
                                color: Colors.blue,
                                tooltip: 'Message',
                                onPressed: () => _makeCall(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.call),
                                color: Colors.green,
                                tooltip: 'Audio Call',
                                onPressed: () => _makeCall(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.video_call),
                                color: Colors.blue.shade900,
                                tooltip: 'Video Call',
                                onPressed: () => _makeCall(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.meeting_room),
                                color: Colors.orange,
                                tooltip: 'Join Meeting',
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_)=>
                                      JoinMeetingScreen(userModel: user,)));

                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )

            ),
          ],
        )

      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}