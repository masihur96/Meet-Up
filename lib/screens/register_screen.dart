import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meet_check/home_screen.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:meet_check/service/fcm_service.dart';


import '../service/local_storage_service.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String? token = await messaging.getToken();

      try {
        String userId = await getDeviceId();

        print(":::::$userId");

        // Sanitize userId to ensure it is safe for Firebase

        // Check if user already exists
        final existingSnapshot = await _database.child('users').child(userId).get();
        if (existingSnapshot.exists) {
          // User already exists
          final existingUser = UserModel.fromMap(Map<String, dynamic>.from(existingSnapshot.value as Map));
          await LocalUserStorage.saveUser(existingUser);
          await FCMService().subscribeForNotification(existingUser);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This user already exists. Loaded existing data.")),
          );

          // Navigate to home screen
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false,
            );
          }

          return;
        }

        // If user does not exist, create a new one
        final user = UserModel(
          id: userId,
          name: _nameController.text.trim(),
          token: token ?? "",
          status: "",
        );

        await _database.child('users').child(userId).set(user.toMap());
        await LocalUserStorage.saveUser(user);
        await FCMService().subscribeForNotification(user);

        // Navigate to home screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }



  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    String deviceId = 'unknown';
    String model = 'unknown_model';
    String osVersion = 'unknown_os';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = sanitize(androidInfo.id ?? 'unknown_android');
      model = sanitize(androidInfo.model ?? 'unknown_model');
      osVersion = sanitize(androidInfo.version.release ?? 'unknown_os');
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = sanitize(iosInfo.identifierForVendor ?? 'unknown_ios');
      model = sanitize(iosInfo.utsname.machine ?? 'unknown_model');
      osVersion = sanitize(iosInfo.systemVersion ?? 'unknown_os');
    }

    // Combined format: ID|Model|OS
    return '$deviceId$model$osVersion';
  }


  String sanitize(String input) {
    // return input.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');
    return input.replaceAll(RegExp(r'[.#$\[\]/\\]'), '_');// Also replace '|'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
} 