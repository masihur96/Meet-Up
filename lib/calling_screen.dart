import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

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

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }


  Future<void> _joinMeeting() async {
    final options = JitsiMeetConferenceOptions(
      serverURL: "https://echo.attendancekeeper.net/", // Or your own server
      room: widget.meetingId,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": !widget.isVideo,
      },
      featureFlags: {
        "welcomepage.enabled": false,
        "call-integration.enabled": false,
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
      appBar: AppBar(
        title: GestureDetector(

          onTap: (){
            _joinMeeting();
          },


            child: Text("Meeting")),
        backgroundColor: Colors.white,
      ),
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
