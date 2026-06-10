import 'package:flutter/material.dart';

// 골드 톤 통일 팔레트
class AppTheme {
  // 메인 골드
  static const Color primary    = Color(0xFFD4A574);  // 골드
  static const Color primaryDark= Color(0xFFBF8A55);  // 진한 골드
  // 세컨더리 (밝은 골드)
  static const Color pinkLight  = Color(0xFFF5E6D3);  // 연한 골드 크림 (핑크 대체)
  static const Color pink       = Color(0xFFE8C99A);  // 미드 골드 (핑크 대체)
  // 옐로우 골드
  static const Color yellow     = Color(0xFFE8C97A);
  static const Color yellowLight= Color(0xFFFAF0DC);
  // 텍스트
  static const Color textDark   = Color(0xFF5C3D2E);
  static const Color textMid    = Color(0xFF8B6F47);
  static const Color textLight  = Color(0xFFB89070);
  // 배경
  static const Color bg         = Color(0xFFFFF8F0);
  static const Color bgCard     = Color(0xFFFFFFFF);
  static const Color bgLight    = Color(0xFFFFF0E0);
  // 보더
  static const Color border     = Color(0xFFEDD8C8);

  // 꽃 이미지 경로
  static const String flowerBg = 'assets/images/flower_bg.png';

  // 골드 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A574), Color(0xFFBF8A55)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C99A), Color(0xFFD4A574)],
  );
}
