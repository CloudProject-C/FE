// lib/main.dart
import 'package:campit_frontend/feature/home/home_screen.dart';
import 'package:campit_frontend/feature/home/daliy_preference_screen.dart';
import 'package:campit_frontend/feature/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:campit_frontend/feature/account/login_screen.dart';

import 'feature/map/map_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await FlutterNaverMap().init(
      clientId: 'vxsqc58u7x',
      onAuthFailed: (ex) => print("인증 실패: $ex"),
    );
  }

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (kIsWeb) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 375,
                  maxHeight: 812,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: child,
                ),
              ),
            ),
          );
        }
        return child!;
      },
      initialRoute: '/',
      routes: {
        '/': (_) => LoginScreen(),
        '/home': (_) => HomeScreen(),
        '/preference': (_) => DaliyFoodPreferenceScreen(),
        '/map': (_) => MapScreen(),
        '/profile': (_) => ProfileScreen(),
      },
    );
  }
}
