import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'survey_screen.dart';
import 'voice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _iconCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 600));
  late final Animation<double> _iconOpacity =
      Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _iconCtrl, curve: Curves.easeIn));

  late final AnimationController _textCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _textOpacity =
      Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));

  bool _showIcon = true;

  @override
  void initState() {
    super.initState();
    _runIntro();
  }

  Future<void> _runIntro() async {
    await _iconCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    await _iconCtrl.reverse();
    if (mounted) setState(() => _showIcon = false);
    await _textCtrl.forward();
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // 전체 배경: 꽃 이미지 매우 연하게 (7%)
          Positioned.fill(
            child: Image.asset(
              AppTheme.flowerBg,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.07),
            ),
          ),
          SafeArea(
            child: _showIcon ? _buildIconPhase() : _buildMainPhase(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPhase() {
    return Center(
      child: FadeTransition(
        opacity: _iconOpacity,
        child: const _AppIcon(size: 200),
      ),
    );
  }

  Widget _buildMainPhase() {
    return FadeTransition(
      opacity: _textOpacity,
      child: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                '일자리 구하세요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'JalnanGothic',
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  height: 1.4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                // 설문으로 시작
                SizedBox(
                  width: double.infinity,
                  height: 68,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SurveyScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Text('📋  설문으로 시작',
                          style: TextStyle(
                              fontFamily: 'JalnanGothic',
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 음성으로 시작
                SizedBox(
                  width: double.infinity,
                  height: 68,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VoiceScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.pinkLight,
                      foregroundColor: AppTheme.textDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: const Text('🎤  음성으로 시작',
                        style: TextStyle(
                            fontFamily: 'JalnanGothic',
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 앱 아이콘 ──────────────────────────────────────────────────
class _AppIcon extends StatelessWidget {
  final double size;
  const _AppIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    final double bigSize   = size * 0.22;
    final double smallSize = size * 0.13;
    final double radius    = size * 0.22;

    return SizedBox(
      width: size, height: size,
      child: Stack(
        children: [
          // ① 꽃 배경 이미지
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              image: const DecorationImage(
                image: AssetImage(AppTheme.flowerBg),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.30),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          // ② 흰색 반투명 오버레이 → 글자 가독성 확보
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: Colors.white.withValues(alpha: 0.42),
            ),
          ),
          // ③ 글자 (진한 갈색 + 흰 shadow로 배경과 분리)
          SizedBox(
            width: size, height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [_glyph('구', bigSize, accent: true)]),
                SizedBox(height: size * 0.02),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _glyph('해', bigSize, accent: true),
                  SizedBox(width: size * 0.02),
                  _glyph('요', smallSize, accent: false),
                ]),
                SizedBox(height: size * 0.02),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _glyph('요', bigSize, accent: true),
                  SizedBox(width: size * 0.015),
                  _glyph('기', smallSize, accent: false),
                  SizedBox(width: size * 0.015),
                  _glyph('서', smallSize, accent: false),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glyph(String ch, double fontSize, {required bool accent}) {
    return Text(
      ch,
      style: TextStyle(
        fontFamily: 'JalnanGothic',
        fontSize: fontSize,
        fontWeight: accent ? FontWeight.bold : FontWeight.w500,
        color: accent ? AppTheme.textDark : AppTheme.textMid,
        height: 1.0,
        shadows: const [
          Shadow(color: Colors.white, blurRadius: 8),
          Shadow(color: Colors.white, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
