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
  final CallService _callService = CallService();
  Timer? _autoEndTimer;
  String _callStatus = "Ringing..."; // Initial call status
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // _startAutoEndTimer();
    _joinMeeting();
  }



  Future<void> _joinMeeting() async {
    try {
      final options = JitsiMeetConferenceOptions(
        serverURL: "https://echo.attendancekeeper.net/",
        room: widget.meetingId,
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": !widget.isVideo,
          "prejoinPageEnabled": false,
          "subject": "${widget.callerName}'s Call",
        },
        featureFlags: {
          "welcomepage.enabled": false,
          "prejoin-page.enabled": false,
          "call-integration.enabled": true,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: widget.callerName,
          email: "",
          avatar: widget.avatarUrl.isEmpty
              ? "https://i.pravatar.cc/100"
              : widget.avatarUrl,
        ),
        // Event callbacks

      );
      await jitsiMeet.join(options);
    } catch (e) {
      setState(() {
        _callStatus = "Failed to join meeting";
      });
      print("Error joining meeting: $e");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _autoEndTimer?.cancel();
    _callService.endCall(); // Ensure call is ended
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                widget.avatarUrl.isEmpty
                    ? "https://i.pravatar.cc/100"
                    : widget.avatarUrl,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _callStatus,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            if (!_isConnected)
              ElevatedButton(
                onPressed: () {
                  _callService.endCall();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}