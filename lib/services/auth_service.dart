import 'package:arkan_app/screens/my_areas.dart';
import 'package:arkan_app/services/area_gate.dart';
import 'package:arkan_app/services/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 🔥 Global SnackBar Key
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Auth {
  Future<void> createUserByEmail({
    required String name, 
    required String email,
    required String password,
    
  }) async {
    try {
         UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user!.updateDisplayName(name);
       await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });
    
      await userCredential.user!.reload();

      await sendEmailVerification();

      showSnackBar('تم إنشاء الحساب بنجاح، فعل الإيميل 👌');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar('الباسورد ضعيف');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('الإيميل مستخدم بالفعل');
      }
    } catch (e) {
      showSnackBar('حصل خطأ');
    }
  }

  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();

      showSnackBar(
        'بعتنالك لينك على الإيميل، افتحه وارجع سجل دخول 👌',
      );
    }
  }

  Future<void> userLogin({
    required String email,
    required String password,
    required BuildContext context, // 👈 لسه محتاجينه للـ Navigation
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseAuth.instance.currentUser!.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
       goToAndRemoveAll(context, AreaGate());
      } else {
        showSnackBar(
          'من فضلك فعل الإيميل الأول قبل تسجيل الدخول',
        );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar('لا يوجد مستخدم بهذا الإيميل');
      } else if (e.code == 'wrong-password') {
        showSnackBar('كلمة المرور غلط');
      } else {
        showSnackBar('خطأ في تسجيل الدخول');
      }
    }
  }

  // ✅ SnackBar بدون context
  void showSnackBar(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}