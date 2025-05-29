import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'call_service.dart'; // Add this import
class FCMService {


  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();


  static Future<void> init() async {
    await Firebase.initializeApp();

    // iOS: request permissions
    await _messaging.requestPermission();

    // Foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background / terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Tap on notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Handle navigation or logic
      _handleMessageData(message.data);
      print('🔔 Notification clicked: ${message.data}');
    });

    await _initLocalNotifications();
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    _handleMessageData(message.data);
    print("🔙 Background Message: ${message.notification?.title}");
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
          print('🔔 Notification tapped: ${response.payload}');
        });
  }

  static void _handleMessageData(Map<String, dynamic> data) {
    if (data['type'] == 'call') {
      CallService().showIncomingCall(
        callerName: data['callerName'] ?? 'Unknown',
        callerId: data['callerId'] ?? 'unknown_id',
        meetingId: data['meetingId'] ?? '',
      );
    }
  }


  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;

    if (data['type'] == 'call') {
      CallService().showIncomingCall(
        callerName: data['callerName'] ?? 'Unknown',
        callerId: data['callerId'] ?? 'unknown_id',
        meetingId: data['meetingId'] ?? '',
      );
      return;
    }

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fcm_channel',
            'FCM Notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: message.data['payload'],
      );
    }
  }



  FirebaseMessaging messaging = FirebaseMessaging
      .instance;
  subscribeForNotification(UserModel user) {
    messaging.subscribeToTopic(user.id);
    print("Subscribed to notifications for user: ${user.id}");
  }

  unSubscribeForNotification(UserModel user) {
    messaging.unsubscribeFromTopic(user.id);
    print("Unsubscribed from notifications for user: ${user.id}");
  }

  Future<void> sendNotification({
    required String recipientToken,
    required UserModel caller,
    required String callId,
  }) async {
    // Service account credentials (replace with your service account JSON)

    final jsonString = await rootBundle.loadString('assets/ignore_directory/service_account.json');
    final jsonData = json.decode(jsonString);


    final serviceAccountJson = jsonData;
    try {

      // Initialize Dio
      final dio = Dio();

      // Generate OAuth 2.0 access token
      final client = http.Client();
      final authClient = await obtainAccessCredentialsViaServiceAccount(
        ServiceAccountCredentials.fromJson(serviceAccountJson),
        ['https://www.googleapis.com/auth/firebase.messaging'],
        client,
      );

      // FCM v1 API endpoint
      final String fcmUrl =
          'https://fcm.googleapis.com/v1/projects/meetup-fd000/messages:send';


      final Map<String, dynamic> message = {
        "message": {
          "token": recipientToken,
          "notification": {
            "title": "Incoming Call",
            "body": "${caller.name} is calling...",
          },
          "data": {
            'type': 'call',
            'callId': callId,
            'callerId': caller.id,
            'callerName': caller.name,
          }
        }
      };

      print("message:::$message");

      // Send the request using Dio
      final response = await dio.post(
        fcmUrl,
        data: jsonEncode(message),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authClient.accessToken.data}',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.data}');
      } else {
        print('Failed to send notification: ${response.statusCode} ${response.data}');
      }

      // Clean up
      client.close();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }






}
