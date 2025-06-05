import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meet_check/screens/messaging_home_page.dart';
import 'package:meet_check/service/call_service.dart';
import 'package:meet_check/service/fcm_service.dart';
import 'package:meet_check/service/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'screens/register_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async{
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FCMService.init();
  CallService().setupCallkitEventHandler(); // ✅ add this


  await Supabase.initialize(
    url: 'https://yljdgsjwiidlfztlzfvg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsamRnc2p3aWlkbGZ6dGx6ZnZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5MDc3MTgsImV4cCI6MjA2MzQ4MzcxOH0.f1uV2nz4YUDLJkyIcy--kOWLqvSruHxgSXzo1MjszOU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialScreen() async {
    final userModel = await LocalUserStorage.getUser();

    if (userModel == null || userModel.name.isEmpty) {
      return const RegisterScreen();
    } else {
      return const MessagingHomePage();
      // return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Meeting App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
      // MessagingHomePage()


      FutureBuilder<Widget>(
        future: getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Something went wrong')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}