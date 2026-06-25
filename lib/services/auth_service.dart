import 'package:arkan_app/screens/login/email_verification_screen.dart';
import 'package:arkan_app/screens/login/login_screen.dart';
import 'package:arkan_app/services/area_gate.dart';
import 'package:arkan_app/services/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

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
    required BuildContext context,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      await userCredential.user!.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'email': email.trim(),
            'createdAt': DateTime.now(),
          });

      await userCredential.user!.reload();

      // ✅ إرسال رابط التفعيل
      await userCredential.user!.sendEmailVerification();

      if (!context.mounted) return;

      // ✅ التوجه لصفحة التحقق
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar('الباسورد ضعيف');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('الإيميل مستخدم بالفعل');
      } else if (e.code == 'invalid-email') {
        showSnackBar('البريد الإلكتروني غير صحيح');
      } else {
        showSnackBar('خطأ في إنشاء الحساب: ${e.message}');
      }
    } catch (e) {
      debugPrint('Create account error: $e');
      showSnackBar('حصل خطأ غير متوقع');
    } finally {
      _isLoading = false;
    }
  }

    // ======================== Google Sign In v7.2 (الحل النهائي) ========================
  Future<void> signInWithGoogle({required BuildContext context}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // 1️⃣ authenticate مع scopeHint
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      if (googleUser == null) {
        _isLoading = false;
        return;
      }

      // 2️⃣ idToken - synchronous (من غير await)
      final googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // 3️⃣ accessToken - عن طريق authorizationClient
      final authClient = googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      // لو authorizationForScopes رجعت null نجرب authorizeScopes
      final String? accessToken = authorization?.accessToken ??
          (await authClient.authorizeScopes(['email', 'profile'])).accessToken;

      // 4️⃣ إنشاء credential بالتوكنين
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      // 5️⃣ Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        showSnackBar('حدث خطأ، حاول مرة أخرى');
        _isLoading = false;
        return;
      }

      // 6️⃣ Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'مستخدم',
          'email': user.email ?? '',
          'createdAt': DateTime.now(),
          'loginMethod': 'google',
        });
      }

      if (!context.mounted) return;

      showSnackBar('تم تسجيل الدخول بنجاح 🎉');
      goToAndRemoveAll(context, AreaGate());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        showSnackBar('هذا البريد مسجل بطريقة أخرى');
      } else if (e.code == 'invalid-credential') {
        showSnackBar('بيانات الاعتماد غير صحيحة');
      } else {
        showSnackBar('خطأ: ${e.message}');
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e"); // ← ده هيظهرلك الخطأ الحقيقي
      showSnackBar('حدث خطأ غير متوقع');
    } finally {
      _isLoading = false;
    }
  }
  // ======================== Apple Sign In ========================

  /// Generates a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple({required BuildContext context}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      // ✅ التحقق من توفر Apple Sign In
      final isAvailable = await SignInWithApple.isAvailable();

      if (!isAvailable) {
        showSnackBar('تسجيل الدخول بـ Apple غير متاح على هذا الجهاز');
        _isLoading = false;
        return;
      }

      // ✅ إنشاء nonce عشوائي
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // ✅ طلب بيانات المصادقة من Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // ✅ إنشاء OAuth credential
      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // ✅ تسجيل الدخول في Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      final user = userCredential.user;

      if (user == null) {
        showSnackBar('حدث خطأ، حاول مرة أخرى');
        return;
      }

      // ✅ حفظ بيانات المستخدم في Firestore (لو أول مرة)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Apple بيرجع الاسم أول مرة بس
        final displayName = appleCredential.givenName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                  .trim()
            : user.displayName ?? 'مستخدم';

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': displayName,
          'email': user.email ?? appleCredential.email ?? '',
          'createdAt': DateTime.now(),
          'loginMethod': 'apple',
        });

        // ✅ تحديث display name في Firebase Auth
        if (displayName.isNotEmpty && user.displayName == null) {
          await user.updateDisplayName(displayName);
        }
      }

      if (!context.mounted) return;

      // ✅ Apple Sign In دايمًا الإيميل verified
      showSnackBar('تم تسجيل الدخول بنجاح 🎉');
      goToAndRemoveAll(context, AreaGate());
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // المستخدم ألغى العملية - مش محتاجين نعرض رسالة
        debugPrint('Apple Sign In canceled by user');
      } else if (e.code == AuthorizationErrorCode.failed) {
        showSnackBar('فشل تسجيل الدخول بـ Apple');
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        showSnackBar('لم يتم معالجة الطلب');
      } else {
        showSnackBar('خطأ في تسجيل الدخول: ${e.code}');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        showSnackBar('هذا البريد مسجل بطريقة أخرى');
      } else if (e.code == 'invalid-credential') {
        showSnackBar('بيانات الاعتماد غير صحيحة');
      } else if (e.code == 'operation-not-allowed') {
        showSnackBar('تسجيل الدخول بـ Apple غير مفعل');
      } else if (e.code == 'user-disabled') {
        showSnackBar('هذا الحساب معطل');
      } else {
        showSnackBar('خطأ في تسجيل الدخول: ${e.message}');
      }
    } catch (e) {
      debugPrint('Apple Sign In error: $e');
      showSnackBar('حدث خطأ غير متوقع');
    } finally {
      _isLoading = false;
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
        email: email.trim(),
        password: password,
      );

      await FirebaseAuth.instance.currentUser!.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showSnackBar('حدث خطأ، حاول مرة أخرى');
        return;
      }

      if (!context.mounted) return;

      if (user.emailVerified) {
        goToAndRemoveAll(context, AreaGate());
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // ✅ الكود الجديد
      if (e.code == 'invalid-credential') {
        showSnackBar('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else if (e.code == 'user-not-found') {
        showSnackBar('لا يوجد مستخدم بهذا البريد الإلكتروني');
      } else if (e.code == 'wrong-password') {
        showSnackBar('كلمة المرور غير صحيحة');
      } else if (e.code == 'invalid-email') {
        showSnackBar('البريد الإلكتروني غير صحيح');
      } else if (e.code == 'user-disabled') {
        showSnackBar('هذا الحساب معطل');
      } else if (e.code == 'too-many-requests') {
        showSnackBar('تم تجاوز عدد المحاولات، حاول بعد قليل');
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
          MaterialPageRoute(builder: (_) => LoginScreen()),
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
  // ======================== Reset Password ========================

  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      showSnackBar(
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني ✅',
      );

      // ✅ نرجع للصفحة السابقة (صفحة تسجيل الدخول)
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar('لا يوجد حساب مسجل بهذا البريد الإلكتروني');
      } else if (e.code == 'invalid-email') {
        showSnackBar('البريد الإلكتروني غير صحيح');
      } else {
        showSnackBar('حدث خطأ: ${e.message}');
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      showSnackBar('حدث خطأ غير متوقع');
    } finally {
      _isLoading = false;
    }
  }
}
