import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:meet_check/service/call_service.dart';

class CallingScreen extends StatefulWidget {
  final String callerName;
  final String meetingId;
  final String avatarUrl;
  final bool isVideo;

  const CallingScreen({
    super.key,
    required this.callerName,
    required this.meetingId,
    this.avatarUrl = "",
    this.isVideo = false,
  });

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final jitsiMeet = JitsiMeet();
  CallService _callService = CallService();
  Timer? _autoEndTimer;
  @override
  void initState() {
    super.initState();
    _autoEndTimer = Timer(Duration(seconds: 30), () {
      print("No participant joined. Ending call.");
      _callService.endCall();
      Navigator.pop(context);
    });
    _joinMeeting();
  }


  Future<void> _joinMeeting() async {
    final options = JitsiMeetConferenceOptions(
      serverURL: "https://echo.attendancekeeper.net/", // Or your own server
      room: widget.meetingId,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": !widget.isVideo,
        "prejoinPageEnabled": false,
      },
      featureFlags: {
        "welcomepage.enabled": false,
        "call-integration.enabled": true,


      },
      userInfo: JitsiMeetUserInfo(
        displayName: widget.callerName,
        email: "", // optional
        avatar: widget.avatarUrl.isEmpty?"https://i.pravatar.cc/100": widget.avatarUrl, // optional
      ),
    );

    await jitsiMeet.join(options);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Connecting to the meeting...",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
