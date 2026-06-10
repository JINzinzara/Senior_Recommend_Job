import 'dart:math' as dart_math;
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
  // 걷기: 900ms 주기
  late final AnimationController _walkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  // 배경 꽃 스크롤: 6초
  late final AnimationController _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000))..repeat();

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
    _msgs = List.of(_allMsgs)..shuffle(dart_math.Random());
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
  void dispose() { _dotCtrl.dispose(); _walkCtrl.dispose(); _bgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8F0),
    body: SafeArea(child: _hasError ? _buildError() : _buildLoading()),
  );

  Widget _buildLoading() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(
        animation: Listenable.merge([_walkCtrl, _bgCtrl]),
        builder: (_, __) => SizedBox(
          width: 300, height: 170,
          child: CustomPaint(
            painter: _GrandparentWalkPainter(
              walkFrame: _walkCtrl.value,
              bgOffset: _bgCtrl.value,
            ),
          ),
        ),
      ),
      const SizedBox(height: 32),
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

// ─────────────────────────────────────────────────────────────────
// 할아버지·할머니 나란히 걷기
// 팔/다리: stroke + StrokeCap.round → 양끝이 자동으로 둥글게, 이음새 자연스러움
// 할머니 다리: 먼저 그리고 치마가 덮음
// ─────────────────────────────────────────────────────────────────
class _GrandparentWalkPainter extends CustomPainter {
  final double walkFrame;
  final double bgOffset;
  const _GrandparentWalkPainter({required this.walkFrame, required this.bgOffset});

  static const double _pi = dart_math.pi;
  double _sin(double x) => dart_math.sin(x);
  double _cos(double x) => dart_math.cos(x);

  // sin에 약한 ease-out 추가 → 발이 뻗을 때 가속, 돌아올 때 부드럽게 감속
  double _gait(double phase) {
    final s = _sin(phase);
    return s * (1.0 + 0.18 * s * s);
  }

  // ── 핵심 헬퍼: 곡선 획(stroke) 그리기 ──────────────────────
  // 양끝이 StrokeCap.round로 자동 마감 → 모서리 튀어나옴 없음
  void _stroke(Canvas canvas, Offset a, Offset ctrl, Offset b, double width, Color color) {
    canvas.drawPath(
      Path()..moveTo(a.dx, a.dy)..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  // 직선 획
  void _strokeLine(Canvas canvas, Offset a, Offset b, double width, Color color) {
    canvas.drawLine(a, b,
      Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h * 0.82;

    _drawBackground(canvas, w, h, groundY);
    _drawFlowers(canvas, w, groundY);
    _drawGrandpa(canvas, w * 0.55, groundY, walkFrame);
    _drawGrandma(canvas, w * 0.43, groundY, walkFrame);
    _drawEdgeFade(canvas, w, h);
  }

  // ── 배경 ──────────────────────────────────────────────────
  void _drawBackground(Canvas canvas, double w, double h, double groundY) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, groundY),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFBBDEFB).withValues(alpha: 0.10),
          const Color(0xFFFFF8F0).withValues(alpha: 0.03),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, groundY)),
    );
    canvas.drawLine(Offset(0, groundY), Offset(w, groundY),
      Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.20)..strokeWidth = 1.5);
  }

  // ── 꽃 ────────────────────────────────────────────────────
  void _drawFlowers(Canvas canvas, double w, double groundY) {
    const pos1 = [0.03, 0.15, 0.28, 0.41, 0.56, 0.69, 0.82, 0.95, 1.08];
    const pos2 = [0.09, 0.22, 0.35, 0.49, 0.62, 0.75, 0.88, 1.01];
    const cols = [
      Color(0xFFFF80AB), Color(0xFFFFD54F), Color(0xFFFF8A65),
      Color(0xFFCE93D8), Color(0xFF80CBC4), Color(0xFFA5D6A7),
    ];
    for (var i = 0; i < pos1.length; i++) {
      final x = ((pos1[i] - bgOffset) % 1.15) * w;
      if (x < -14 || x > w + 14) continue;
      _drawFlower(canvas, x, groundY, cols[i % cols.length], 4.2);
    }
    for (var i = 0; i < pos2.length; i++) {
      final x = ((pos2[i] - bgOffset * 0.6) % 1.1) * w;
      if (x < -10 || x > w + 10) continue;
      _drawFlower(canvas, x, groundY + 5, cols[(i + 2) % cols.length], 3.0);
    }
  }

  void _drawFlower(Canvas canvas, double cx, double gy, Color color, double r) {
    _strokeLine(canvas, Offset(cx, gy), Offset(cx, gy - r * 2.6), 1.1,
      const Color(0xFF66BB6A).withValues(alpha: 0.50));
    final fc = Offset(cx, gy - r * 2.6);
    final petal = Paint()..color = color.withValues(alpha: 0.50);
    for (int i = 0; i < 6; i++) {
      final a = i * _pi / 3;
      canvas.drawCircle(Offset(fc.dx + _cos(a) * r * 0.82, fc.dy + _sin(a) * r * 0.82), r * 0.76, petal);
    }
    canvas.drawCircle(fc, r * 0.52,
      Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: 0.85));
  }

  // ── 가장자리 페이드 ───────────────────────────────────────
  void _drawEdgeFade(Canvas canvas, double w, double h) {
    const bg = Color(0xFFFFF8F0);
    final fw = w * 0.19;
    canvas.drawRect(Rect.fromLTWH(0, 0, fw, h),
      Paint()..shader = LinearGradient(colors: [bg, bg.withValues(alpha: 0)])
        .createShader(Rect.fromLTWH(0, 0, fw, h)));
    canvas.drawRect(Rect.fromLTWH(w - fw, 0, fw, h),
      Paint()..shader = LinearGradient(colors: [bg.withValues(alpha: 0), bg])
        .createShader(Rect.fromLTWH(w - fw, 0, fw, h)));
  }

  // ── 할아버지 ──────────────────────────────────────────────
  void _drawGrandpa(Canvas canvas, double cx, double groundY, double frame) {
    final phase  = frame * 2 * _pi;
    final swing  = _gait(phase) * 12.0;
    final bob    = _sin(phase * 2).abs() * 1.8;

    const skin    = Color(0xFFE3B48C);
    const skinShd = Color(0xFFCC9462);
    const hair    = Color(0xFFB0BEC5);
    const sweater = Color(0xFF7B4F2E);
    const pants   = Color(0xFF4A6270);
    const shoe    = Color(0xFF3E2723);
    const caneCol = Color(0xFF9C7B6B);

    final headR    = 12.0;
    final top      = groundY - 98 - bob;
    final headCY   = top + headR;
    final shldrY   = headCY + headR + 3;  // 어깨 y
    final hipY     = shldrY + 34;          // 허리 y
    final kneeY    = hipY + 20;            // 무릎 y

    // ①  뒤 다리 (stroke, 무릎 굴곡 포함)
    _stroke(canvas,
      Offset(cx - 2, hipY),
      Offset(cx - 2 - swing * 0.30, kneeY),
      Offset(cx - swing * 0.82, groundY - 6),
      10, pants);
    // 뒤 신발
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - swing * 0.82 + 1, groundY - 3), width: 14, height: 7),
      const Radius.circular(4)), Paint()..color = shoe);

    // ②  몸통 (filled rounded rect) + 칼라
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 11, shldrY, 22, hipY - shldrY),
      const Radius.circular(8)), Paint()..color = sweater);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 1, shldrY + 4),
      width: 9, height: 7), Paint()..color = Colors.white);

    // ③  어깨 원 (어깨-팔 이음새를 부드럽게)
    canvas.drawCircle(Offset(cx - 9, shldrY + 3), 5.5, Paint()..color = sweater);
    canvas.drawCircle(Offset(cx + 9, shldrY + 3), 5.5, Paint()..color = sweater);

    // ④  뒤 팔 (stroke)
    _stroke(canvas,
      Offset(cx - 9, shldrY + 5),
      Offset(cx - 12 - swing * 0.22, shldrY + 16),
      Offset(cx - 10 - swing * 0.45, shldrY + 24),
      9, sweater);

    // ⑤  앞 팔 + 지팡이 (stroke)
    final fWristX = cx + 10 + swing * 0.45;
    final fWristY = shldrY + 24;
    _stroke(canvas,
      Offset(cx + 9, shldrY + 5),
      Offset(cx + 12 + swing * 0.22, shldrY + 16),
      Offset(fWristX, fWristY),
      9, sweater);
    // 지팡이 몸체
    _strokeLine(canvas,
      Offset(fWristX + 3, fWristY),
      Offset(fWristX + 7, groundY),
      2.0, caneCol);
    // 지팡이 손잡이
    canvas.drawArc(
      Rect.fromCenter(center: Offset(fWristX + 1, fWristY - 3), width: 8, height: 6),
      _pi * 0.4, _pi * 1.2, false,
      Paint()..color = caneCol..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap = StrokeCap.round);

    // ⑥  앞 다리
    _stroke(canvas,
      Offset(cx + 2, hipY),
      Offset(cx + 2 + swing * 0.30, kneeY),
      Offset(cx + swing, groundY - 6),
      10, pants);
    // 앞 신발
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + swing + 2, groundY - 3), width: 14, height: 7),
      const Radius.circular(4)), Paint()..color = shoe);

    // ⑦  머리
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, headCY),
      width: headR * 2, height: headR * 2.1), Paint()..color = skin);
    // 머리카락: stroke arc → 자연스러운 반달 모양
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 1, headCY - 1), width: headR * 2, height: headR * 2),
      _pi * 0.72, _pi * 1.35, false,
      Paint()..color = hair..strokeWidth = 5.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
    // 안경
    canvas.drawCircle(Offset(cx + 6, headCY + 2), 4.8,
      Paint()..color = const Color(0xFF6D4C41)..style = PaintingStyle.stroke..strokeWidth = 1.6);
    // 코 (옆면)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + headR - 0.5, headCY + 3.5),
      width: 5, height: 3.5), Paint()..color = skinShd);
    // 귀
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - headR + 1, headCY + 1),
      width: 5, height: 7), Paint()..color = skin);
  }

  // ── 할머니 ────────────────────────────────────────────────
  void _drawGrandma(Canvas canvas, double cx, double groundY, double frame) {
    final phase  = frame * 2 * _pi + _pi;
    final swing  = _gait(phase) * 9.5;
    final bob    = _sin(phase * 2).abs() * 1.8;

    const skin     = Color(0xFFEDC9A0);
    const skinShd  = Color(0xFFCC9462);
    const hair     = Color(0xFFCFD8DC);
    const dress    = Color(0xFFC0392B);
    const dressDark= Color(0xFF922B21);
    const shoe     = Color(0xFFF0A500);
    const dotCol   = Color(0xFFE59A2F);

    final headR    = 11.0;
    final top      = groundY - 85 - bob;
    final headCY   = top + headR;
    final shldrY   = headCY + headR + 3;
    final hipY     = shldrY + 31;
    final skirtHem = groundY - 6;

    // ①  뒤 다리 먼저 (치마가 나중에 덮음)
    _stroke(canvas,
      Offset(cx - 2, hipY + 4),
      Offset(cx - 2 - swing * 0.28, hipY + 14),
      Offset(cx - swing * 0.78, groundY - 6),
      9, dressDark);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - swing * 0.78 + 1, groundY - 3), width: 12, height: 6.5),
      const Radius.circular(3)), Paint()..color = shoe);

    // ②  앞 다리
    _stroke(canvas,
      Offset(cx + 2, hipY + 4),
      Offset(cx + 2 + swing * 0.28, hipY + 14),
      Offset(cx + swing, groundY - 6),
      9, dressDark);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + swing + 1.5, groundY - 3), width: 12, height: 6.5),
      const Radius.circular(3)), Paint()..color = shoe);

    // ③  원피스 몸통 + 치마 (다리 윗부분 덮음)
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 13, shldrY, 26, hipY - shldrY),
      const Radius.circular(9)), Paint()..color = dress);
    // 치마 (아래로 퍼짐)
    canvas.drawPath(Path()
      ..moveTo(cx - 13, shldrY + (hipY - shldrY) * 0.52)
      ..lineTo(cx - 17, skirtHem)
      ..lineTo(cx + 17, skirtHem)
      ..lineTo(cx + 13, shldrY + (hipY - shldrY) * 0.52)
      ..close(), Paint()..color = dress);
    // 밑단
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 17, skirtHem - 2, 34, 3.5),
      const Radius.circular(1.5)), Paint()..color = dressDark);
    // 칼라
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 1, shldrY + 3),
      width: 8, height: 6), Paint()..color = Colors.white);
    // 별 패턴
    final dotP = Paint()..color = dotCol..strokeWidth = 1.2..style = PaintingStyle.stroke;
    for (final off in const [Offset(-5, 10), Offset(5, 10), Offset(-4, 20), Offset(4, 20), Offset(0, 15)]) {
      _star(canvas, cx + off.dx, shldrY + off.dy, 3.0, dotP);
    }

    // ④  어깨 원
    canvas.drawCircle(Offset(cx - 11, shldrY + 3), 5.0, Paint()..color = dress);
    canvas.drawCircle(Offset(cx + 11, shldrY + 3), 5.0, Paint()..color = dress);

    // ⑤  뒤 팔
    _stroke(canvas,
      Offset(cx - 11, shldrY + 5),
      Offset(cx - 13 - swing * 0.18, shldrY + 14),
      Offset(cx - 10 - swing * 0.38, shldrY + 21),
      8.5, dress);

    // ⑥  앞 팔
    _stroke(canvas,
      Offset(cx + 11, shldrY + 5),
      Offset(cx + 13 + swing * 0.18, shldrY + 14),
      Offset(cx + 10 + swing * 0.38, shldrY + 21),
      8.5, dress);

    // ⑦  머리
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, headCY),
      width: headR * 2, height: headR * 2.1), Paint()..color = skin);
    // 머리카락 (stroke arc)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 1, headCY - 1), width: headR * 2, height: headR * 2),
      _pi * 0.68, _pi * 1.42, false,
      Paint()..color = hair..strokeWidth = 5.0..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
    // 쪽머리
    canvas.drawCircle(Offset(cx - headR + 2, headCY - headR + 1), 5,
      Paint()..color = hair);
    // 안경
    canvas.drawCircle(Offset(cx + 5, headCY + 2), 4.0,
      Paint()..color = const Color(0xFF6D4C41)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // 코
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + headR - 0.5, headCY + 3),
      width: 4, height: 3), Paint()..color = skinShd);
    // 귀
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - headR + 1, headCY + 1),
      width: 4.5, height: 6), Paint()..color = skin);
  }

  // ── 별 패턴 ───────────────────────────────────────────────
  void _star(Canvas canvas, double cx, double cy, double r, Paint p) {
    for (int i = 0; i < 6; i++) {
      final a = i * _pi / 3;
      canvas.drawLine(Offset(cx, cy), Offset(cx + _cos(a) * r, cy + _sin(a) * r), p);
    }
  }

  @override
  bool shouldRepaint(_GrandparentWalkPainter old) =>
      old.walkFrame != walkFrame || old.bgOffset != bgOffset;
}
