import 'package:flutter/material.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:meet_check/service/call_service.dart';

import 'package:uuid/uuid.dart';


class MakeCallScreen extends StatefulWidget {
  final UserModel userModel;
  const MakeCallScreen({super.key,required this.userModel});

  @override
  _MakeCallScreenState createState() => _MakeCallScreenState();
}

class _MakeCallScreenState extends State<MakeCallScreen> {
  final TextEditingController _receiverIdController = TextEditingController();
  final TextEditingController _meetingIdController = TextEditingController();
  final CallService _callService = CallService();

  void _makeCall() async {


    // Here you would typically make an API call to your backend
    // to initiate the call and notify the receiver
    // For demonstration, we'll just show the incoming call UI
    await _callService.showIncomingCall(
      callerName: 'Test Caller',
      callerId: _receiverIdController.text,
      meetingId: _meetingIdController.text,
    );
    await _callService.showIncomingCall(
      callerName: 'Masihur Rohman',
      callerId: "callerTest",
      meetingId: "meetingTest",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _receiverIdController,
              decoration: const InputDecoration(
                labelText: 'Receiver ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _meetingIdController,
              decoration: const InputDecoration(
                labelText: 'Meeting ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _makeCall,
              child: const Text('Make Call'),
            ),
          ],
        ),
      ),
    );
  }
} 