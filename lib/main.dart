import 'package:arkan_app/generated/l10n.dart';
import 'package:arkan_app/services/auth_gate.dart';
import 'package:arkan_app/services/auth_service.dart';
import 'package:arkan_app/shared/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screens/imports.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Import the generated file
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   await GoogleSignIn.instance.initialize(
    serverClientId: '433084147989-976ep8gd1grgtmn0ahq7eqgbcfknq5u9.apps.googleusercontent.com',
  );
  runApp(
    Directionality(textDirection: TextDirection.rtl, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      locale: const Locale('ar'),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      scaffoldMessengerKey: messengerKey,
      home:
          // Directionality(
          //   textDirection: TextDirection.rtl,
          // child:
          SplashScreen(),
    );
  }
}
