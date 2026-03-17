import 'package:flutter/material.dart';
import 'package:my_chatapp/services/auth/auth_gate.dart';
//import 'package:my_chatapp/auth/user.dart';
//import 'package:my_chatapp/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_chatapp/themes/light_mode.dart';
import 'firebase_options.dart';
//import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      theme: lightMode,
    );
  }
}

//Upto 20:42
