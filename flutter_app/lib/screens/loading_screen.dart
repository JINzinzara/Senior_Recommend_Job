import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class LoadingScreen extends StatefulWidget {
  final Map<String, dynamic> answers;
  const LoadingScreen({super.key, required this.answers});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late final AnimationController _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  late final AnimationController _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

  static const List<String> _allMsgs = [
    '공고를 분석하는 중...', '설문 답변과 일치하는 공고 찾는 중...', '지역 정보를 확인하는 중...', '최적의 일자리를 선정하는 중...',
    '토닥토닥, 고생하셨어요', '잠시 쉬어가도 괜찮아요', '내일은 더 눈부실거에요', '지금도 충분히 멋져요',
    '신발이 화나면? 신발끈!', '피자가 웃으면? 피자헛!', '우유가 아프면? 앙팡!', '부엉이가 물에 빠지면? 첨부엉 첨부엉!',
  ];
  late List<String> _msgs;
  int _msgIdx = 0;
  bool _hasError = false;
  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    // 전체 목록 셔플 후 순서대로 순환 (같은 문구 연속 방지)
    _msgs = List.of(_allMsgs)..shuffle(Random());
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() => _msgIdx = (_msgIdx + 1) % _msgs.length);
      return true;
    });
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final a = widget.answers;
      final results = await ApiService.getRecommendations(
        q1: List<String>.from(a['Q1']), q2: List<String>.from(a['Q2']),
        q3: a['Q3'], q4: a['Q4'], q5: a['Q5'],
        q6: List<String>.from(a['Q6']), q7: a['Q7'], q8: a['Q8'],
      ).timeout(const Duration(seconds: 60));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultScreen(recommendations: results)));
    } catch (e) {
      if (!mounted) return;
      setState(() { _hasError = true; _errMsg = e.toString(); });
    }
  }

  @override
  void dispose() { _dotCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8F0),
    body: SafeArea(child: _hasError ? _buildError() : _buildLoading()),
  );

  Widget _buildLoading() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(animation: _pulseCtrl, builder: (_, _) => Transform.scale(
        scale: 1.0 + _pulseCtrl.value * 0.08,
        child: Container(width: 100, height: 100,
          decoration: BoxDecoration(color: const Color(0xFFD4A574), borderRadius: BorderRadius.circular(28)),
          child: const Icon(Icons.search_rounded, size: 56, color: Colors.white)),
      )),
      const SizedBox(height: 40),
      const Text('나에게 딱 맞는\n일자리를 찾고 있어요', textAlign: TextAlign.center,
        style: TextStyle(fontFamily:'JalnanGothic', fontSize:28, fontWeight:FontWeight.bold, color:Color(0xFF5C3D2E), height:1.4)),
      const SizedBox(height: 20),
      AnimatedBuilder(animation: _dotCtrl, builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final v = (_dotCtrl.value + 1 - i / 3) % 1.0;
          final op = (v < 0.5 ? v * 2 : (1 - v) * 2).clamp(0.2, 1.0);
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Opacity(opacity: op, child: const CircleAvatar(radius: 6, backgroundColor: Color(0xFFD4A574))));
        }),
      )),
      const SizedBox(height: 20),
      Text(_msgs[_msgIdx], textAlign: TextAlign.center,
        style: const TextStyle(fontFamily:'JalnanGothic', fontSize:16, color:Color(0xFF8B6F47))),
    ]),
  ));

  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline_rounded, size: 72, color: Color(0xFFEF4444)),
      const SizedBox(height: 24),
      const Text('오류가 발생했어요', style: TextStyle(fontFamily:'JalnanGothic', fontSize:24, fontWeight:FontWeight.bold, color:Color(0xFF5C3D2E))),
      const SizedBox(height: 12),
      Text(_errMsg, textAlign: TextAlign.center, style: const TextStyle(fontFamily:'JalnanGothic', fontSize:14, color:Color(0xFF8B6F47))),
      const SizedBox(height: 32),
      SizedBox(width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18),
            side: const BorderSide(color: Color(0xFFD4A574)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: const Text('돌아가기', style: TextStyle(fontFamily:'JalnanGothic', fontSize:18, color:Color(0xFFD4A574))),
        )),
    ]),
  ));
}
