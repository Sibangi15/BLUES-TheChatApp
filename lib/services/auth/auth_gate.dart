import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chatapp/screens/home_screen.dart';
import 'package:my_chatapp/services/auth/user.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {

        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const UserAuth();
        }
      }),
    );
  }
}