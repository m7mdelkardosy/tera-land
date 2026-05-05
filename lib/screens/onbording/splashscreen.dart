import 'package:arkan_app/services/auth_gate.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> scale;
  late Animation<double> fade;
  late Animation<double> rotation;
  late Animation<double> drop;
  late Animation<double> glow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // ✨ ظهور وتكبير ناعم
    scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: const Interval(0.0, 0.3),
      ),
    );

    // 🔄 حركة اهتزاز دائرية للوجو
    rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    // 📍 سقوط السهم من أعلى الشاشة
    // تم ضبط البداية من -150 ليكون أقرب كما طلبت
    drop = Tween<double>(begin: -150.0, end: -35.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.bounceOut),
      ),
    );

    // 💡 نبض التوهج الخلفي
    glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 40.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 40.0, end: 10.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // الانتقال للشاشة التالية عند انتهاء الأنيميشن
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // تم دمج الجرادينت بحيث يحتوي على كل محتوى الصفحة
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF2D5A5A), // تيل لايت في المنتصف
              Color(0xFF0A1A1A), // تيل غامق للأطراف
            ],
          ),
        ),
        child: SizedBox.expand(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: fade.value,
                  child: Transform.scale(
                    scale: scale.value,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        
                        // 💡 الطبقة الأولى: التوهج (Glow)
                        Container(
                          width: size.width * 0.5,
                          height: size.width * 0.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(0.2),
                                blurRadius: glow.value,
                                spreadRadius: glow.value / 2,
                              ),
                            ],
                          ),
                        ),

                        // 🟢 الطبقة الثانية: اللوجو
                        Transform.rotate(
                          angle: rotation.value,
                          child: Image.asset(
                            'assets/images/splash1.png',
                            width: size.width * 0.65,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // 📍 الطبقة الثالثة: السهم الكبير
                        Transform.translate(
                          offset: Offset(0, drop.value),
                          child: Image.asset(
                            'assets/images/sahm.png', 
                            width: size.width * 0.38, 
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}