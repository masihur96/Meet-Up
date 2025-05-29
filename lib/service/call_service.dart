import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meet_check/calling_screen.dart';
import 'package:meet_check/main.dart';
import 'package:uuid/uuid.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  String? _currentCallId; // 🆕 Store current call UUID

  Future<void> showIncomingCall({
    required String callerName,
    required String callerId,
    required String meetingId,
  }) async {
    final uuid = const Uuid().v4(); // Generate unique call ID
    _currentCallId = uuid; // Save call ID for ending the call later

    final params = CallKitParams(
      id: uuid,
      nameCaller: callerName,
      appName: 'Meet Check',
      avatar: 'https://i.pravatar.cc/100', // optional avatar
      handle: callerId,
      type: 0, // 0 = audio, 1 = video
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',

      extra: <String, dynamic>{'meetingId': meetingId},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }



  void setupCallkitEventHandler() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      final eventType = event?.event;
      final data = event?.body;

      print("📞 CallKit Event: $eventType");
      print("📞 CallKit Event: ${data['extra']['meetingId']}");

      switch (eventType) {
        case Event.actionCallAccept:
          final meetingId = data?['extra']['meetingId'];
          final nameCaller = data?['nameCaller'];
          _onCallAccepted(meetingId,nameCaller);
          break;

        case Event.actionCallDecline:
          print("❌ Call declined");
          break;

        case Event.actionCallEnded:
          print("📴 Call ended");
          break;

        default:
          print("🔄 Unhandled event: $eventType");
      }
    });
  }


  void _onCallAccepted(String? meetingId,String? callerName) {
    if (meetingId == null) {
      print("⚠️ No meetingId provided");
      return;
    }

    // Navigate to your call/meeting screen (using context, routing, etc.)
    // You may use a service or global navigator key
    print("✅ Accepted call with meetingId: $meetingId");

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => CallingScreen(
          callerName: callerName ?? "Unknown Caller",
          meetingId: meetingId,
        ),
      ),
          (route) => false, // Remove all previous routes
    );
  }


  late Timer _callingTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> startCallingBeep() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/calling_beep.mp3');

      _callingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      });
    } catch (e) {
      print('Failed to play beep: $e');
    }
  }

  void stopCallingBeep() {
    _callingTimer.cancel();
    _audioPlayer.stop();
  }


  Future<void> endCall() async {
    if (_currentCallId != null) {
      await FlutterCallkitIncoming.endCall(_currentCallId!);
      _currentCallId = null; // Reset after ending
    } else {
      print("No active call to end.");
    }
  }
}
