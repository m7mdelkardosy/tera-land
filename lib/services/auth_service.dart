import 'package:arkan_app/screens/login/login_screen.dart';
import 'package:arkan_app/services/area_gate.dart';
import 'package:arkan_app/services/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 🔥 Global SnackBar Key
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Auth {
  // ✅ حماية من الضغط المتكرر
  static bool _isLoading = false;

  // ======================== Create Account ========================

  Future<void> createUserByEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

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
      } else {
        showSnackBar('خطأ في إنشاء الحساب');
      }
    } catch (e) {
      debugPrint('Create account error: $e');
      showSnackBar('حصل خطأ غير متوقع');
    } finally {
      _isLoading = false;
    }
  }

  // ======================== Email Verification ========================

  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        showSnackBar('بعتنالك لينك على الإيميل، افتحه وارجع سجل دخول 👌');
      } catch (e) {
        debugPrint('Email verification error: $e');
        showSnackBar('حصل خطأ في إرسال رسالة التفعيل');
      }
    }
  }

  // ======================== Login ========================

  Future<void> userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseAuth.instance.currentUser!.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        if (context.mounted) {
          goToAndRemoveAll(context, AreaGate());
        }
      } else {
        showSnackBar('من فضلك فعل الإيميل الأول قبل تسجيل الدخول');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar('لا يوجد مستخدم بهذا الإيميل');
      } else if (e.code == 'wrong-password') {
        showSnackBar('كلمة المرور غلط');
      } else {
        showSnackBar('خطأ في تسجيل الدخول');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      showSnackBar('حصل خطأ غير متوقع');
    } finally {
      _isLoading = false;
    }
  }

  // ======================== Sign Out ========================

  static bool _isSigningOut = false;

  Future<void> signOut(BuildContext context) async {
    // ✅ منع الضغط مرتين
    if (_isSigningOut) return;
    _isSigningOut = true;

    try {
      // ✅ لو جوه Drawer نقفله الأول
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // ✅ Sign out
      await FirebaseAuth.instance.signOut();

      // ✅ يروح لصفحة تسجيل الدخول ويمسح كل الصفحات القديمة
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => LoginScreen(), 
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Sign out error: $e');
      showSnackBar('حدث خطأ أثناء تسجيل الخروج');
    } finally {
      _isSigningOut = false;
    }
  }

  // ======================== SnackBar ========================

  void showSnackBar(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF1F3F45),
      ),
    );
  }
}