import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:meet_check/screens/bounching_dialog.dart';
import 'package:meet_check/screens/custom_size.dart';
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
  StreamSubscription<DatabaseEvent>? _usersSubscription;

  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isLoading = false;



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
                                icon: const Icon(Icons.meeting_room),
                                color: Colors.orange,
                                tooltip: 'Join Meeting',
                                onPressed: () {


                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) {
                                      final TextEditingController meetingIdController = TextEditingController();

                                      return BounchingDialog(
                                        width: screenSize(context, 0.6),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Join Meeting',
                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 20),
                                              TextField(
                                                controller: meetingIdController,
                                                decoration: InputDecoration(
                                                  labelText: 'Meeting ID',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context), // Close dialog
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {

                                                      if (meetingIdController.text.isEmpty) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Please fill in all fields')),
                                                        );
                                                        return;
                                                      }else{

                                                        // Validate meeting ID format if necessary
                                                        final meetingId = meetingIdController.text.trim();
                                                        if (meetingId.isNotEmpty) {
                                                          Navigator.pop(context); // Close dialog
                                                          _joinMeeting(meetingId,userModel!); // Pass ID to your join function
                                                        }
                                                      }



                                                    },
                                                    child: Text('Join'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );

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

  void _joinMeeting(String meetingId,UserModel user) async {
    final JitsiMeet jitsiMeet = JitsiMeet();
    setState(() {
      _isLoading = true;
    });

    try {
      var options = JitsiMeetConferenceOptions(
        serverURL: "https://echo.attendancekeeper.net/",
        configOverrides: {
          "startWithAudioMuted": !_isAudioEnabled,
          "startWithVideoMuted": !_isVideoEnabled,
          "subject": "Jitsi Meetup",
        },
        featureFlags: {
          "unsaferoomwarning.enabled": false,
          "welcomepage.enabled": false,
        },
        room: meetingId,
        userInfo: JitsiMeetUserInfo(
          displayName: user.name,
        ),
      );

      await jitsiMeet.join(options);
    } catch (error) {
      debugPrint("Error joining meeting: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining meeting: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}