import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SeniorJobApp());
}

class SeniorJobApp extends StatelessWidget {
  const SeniorJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시니어 일자리 추천',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'JalnanGothic',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4A574)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
