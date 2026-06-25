import 'dart:async';
import 'package:arkan_app/screens/login/login_screen.dart';
import 'package:arkan_app/services/area_gate.dart';
import 'package:arkan_app/services/auth_service.dart';
import 'package:arkan_app/services/navigation.dart';
import 'package:arkan_app/shared/themes/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  bool _canResend = true;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  Timer? _autoCheckTimer;

  

  @override
  void initState() {
    super.initState();
    // ✅ بنتشيك كل 3 ثواني تلقائيًا لو المستخدم فعّل الإيميل
    _startAutoCheck();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  // ======================== Auto Check ========================

  void _startAutoCheck() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkEmailVerified(isAutoCheck: true);
    });
  }

  // ======================== Check Verification ========================

  Future<void> _checkEmailVerified({bool isAutoCheck = false}) async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // ✅ لو اليوزر null معناه حصل مشكلة
        _handleLogout();
        return;
      }

      // ✅ نعمل reload للبيانات من Firebase
      await user.reload();

      // ✅ نجيب اليوزر بعد الـ reload
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        _handleLogout();
        return;
      }

      // ✅ لو الإيميل متفعل
      if (refreshedUser.emailVerified) {
        _autoCheckTimer?.cancel();

        if (!mounted) return;

        Auth().showSnackBar('تم تفعيل الحساب بنجاح 🎉');

        // ✅ نروح لصفحة المناطق
        goToAndRemoveAll(context, AreaGate());
        return;
      }

      // ✅ لو مش auto check ومش متفعل
      if (!isAutoCheck && mounted) {
        Auth().showSnackBar('الإيميل لم يتم تفعيله بعد');
      }
    } catch (e) {
      debugPrint('Check verification error: $e');

      if (!isAutoCheck && mounted) {
        Auth().showSnackBar('حدث خطأ أثناء التحقق');
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  // ======================== Resend Email ========================

  Future<void> _resendVerificationEmail() async {
    if (_isResending || !_canResend) return;

    setState(() => _isResending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _handleLogout();
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) return;

      Auth().showSnackBar('تم إعادة إرسال رابط التفعيل بنجاح ✅');

      // ✅ نبدأ عداد 60 ثانية قبل ما نسمحله يبعت تاني
      _startResendCountdown();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        Auth().showSnackBar('تم إرسال الكثير من الطلبات، حاول بعد قليل');
      } else {
        Auth().showSnackBar('حدث خطأ: ${e.message}');
      }
    } catch (e) {
      debugPrint('Resend email error: $e');
      Auth().showSnackBar('حدث خطأ غير متوقع');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  // ======================== Countdown Timer ========================

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  // ======================== Logout ========================

  void _handleLogout() {
    _autoCheckTimer?.cancel();
    _countdownTimer?.cancel();

    if (!mounted) return;

    Auth().showSnackBar('حدثت مشكلة، يرجى تسجيل الدخول مجددًا');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) =>  LoginScreen()), // ← غيّر للاسم الصحيح
      (route) => false,
    );
  }

  // ======================== Build ========================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return WillPopScope(
      // ✅ منع الرجوع بزرار الـ Back
      onWillPop: () async => false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: backgrround,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1F3F45),
            elevation: 0,
            automaticallyImplyLeading: false, // ✅ نخفي زرار الرجوع
            title: const Text(
              'تفعيل الحساب',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _handleLogout,
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ أيقونة الإيميل
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 100,
                    color: Color(0xFF1F3F45),
                  ),
                  const SizedBox(height: 24),

                  // ✅ العنوان
                  const Text(
                    'تحقق من بريدك الإلكتروني',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Color(0xFF1F3F45),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ الوصف
                  Text(
                    'تم إرسال رابط التفعيل إلى:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ✅ الإيميل
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: Color(0xFF1F3F45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ الخطوات
                  _buildStepCard(
                    number: '1',
                    text: 'افتح بريدك الإلكتروني',
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    number: '2',
                    text: 'اضغط على رابط التفعيل',
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    number: '3',
                    text: 'ارجع واضغط "تأكيد التفعيل"',
                  ),
                  const SizedBox(height: 32),

                  // ✅ زر التحقق
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isChecking
                          ? null
                          : () => _checkEmailVerified(isAutoCheck: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3F45),
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline,
                              color: Colors.white),
                      label: Text(
                        _isChecking ? 'جاري التحقق...' : 'تأكيد التفعيل',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ زر إعادة الإرسال
                  OutlinedButton.icon(
                    onPressed: (_isResending || !_canResend)
                        ? null
                        : _resendVerificationEmail,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF1F3F45),
                      side: BorderSide(
                        color: _canResend
                            ? const Color(0xFF1F3F45)
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isResending
                          ? 'جاري الإرسال...'
                          : _canResend
                              ? 'إعادة إرسال رابط التفعيل'
                              : 'يمكنك الإرسال بعد $_resendCountdown ث',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ ملاحظة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'لم تجد الرسالة؟ تحقق من مجلد الرسائل غير المرغوب فيها (Spam)',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              color: Colors.amber.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ======================== Step Card Widget ========================

  Widget _buildStepCard({required String number, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1F3F45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                color: Color(0xFF1F3F45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}