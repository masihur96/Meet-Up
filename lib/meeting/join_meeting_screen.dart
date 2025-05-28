import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:meet_check/make_call_screen.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:meet_check/service/call_service.dart';

import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';


class JoinMeetingScreen extends StatefulWidget {
  final UserModel userModel;
  const JoinMeetingScreen({super.key,required this.userModel});

  @override
  _JoinMeetingScreenState createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final JitsiMeet jitsiMeet = JitsiMeet();
  final CallService _callService = CallService();
  
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupCallKit();
  }

  @override
  void dispose() {
    super.dispose();
    jitsiMeet.closeChat();
  }

  void _setupCallKit() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallIncoming:
          print('📞 Incoming call: ${event.body}');
          break;

        case Event.actionCallAccept:
          print('✅ Call accepted');
          _joinMeeting();
          break;

        case Event.actionCallDecline:
          print('❌ Call declined');
          CallService().endCall();
          break;

        case Event.actionCallEnded:
          print('🔚 Call ended');
          CallService().endCall();
          break;

        case Event.actionCallTimeout:
          print('⏱️ Call timeout');
          CallService().endCall();
          break;

        case Event.actionCallCallback:
          print('📲 Callback');
          break;

        default:
          print('Unhandled event: ${event.event}');
          break;
      }
    });
  }



  void _joinMeeting() async {
    if (_meetingIdController.text.isEmpty || _userNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var options = JitsiMeetConferenceOptions(
        serverURL: "https://echo.attendancekeeper.net/",
        configOverrides: {
          "startWithAudioMuted": !_isAudioEnabled,
          "startWithVideoMuted": !_isVideoEnabled,
          "subject": "Jitsi with Flutter",
        },
        featureFlags: {
          "unsaferoomwarning.enabled": false,
          "welcomepage.enabled": false,
        },
        room: _meetingIdController.text,
        userInfo: JitsiMeetUserInfo(
          displayName: _userNameController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'New Meeting',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MakeCallScreen(userModel: UserModel(id: "id", name: "name"),),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.video_camera_front_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _meetingIdController.text.isEmpty
                              ? 'No Meeting ID'
                              : _meetingIdController.text,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _meetingIdController,
                            decoration: InputDecoration(
                              labelText: 'Meeting ID',
                              prefixIcon: const Icon(Icons.meeting_room),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _userNameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMediaControl(
                                icon: _isAudioEnabled
                                    ? Icons.mic
                                    : Icons.mic_off,
                                label: 'Audio',
                                isEnabled: _isAudioEnabled,
                                onTap: () {
                                  setState(() {
                                    _isAudioEnabled = !_isAudioEnabled;
                                  });
                                },
                              ),
                              _buildMediaControl(
                                icon: _isVideoEnabled
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                label: 'Video',
                                isEnabled: _isVideoEnabled,
                                onTap: () {
                                  setState(() {
                                    _isVideoEnabled = !_isVideoEnabled;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _joinMeeting,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Join Meeting',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaControl({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}