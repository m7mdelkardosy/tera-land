import 'package:arkan_app/screens/area_listUI.dart';
import 'package:arkan_app/screens/login/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // لسه بيحمل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // المستخدم مش مسجل
        if (!snapshot.hasData) {
          return SignupScreen(); // أو Signup
        }

        // المستخدم مسجل
        return const AreaList(); // الصفحة الرئيسية
      },
    );
  }
}
