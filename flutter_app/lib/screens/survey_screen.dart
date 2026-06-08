import 'package:flutter/material.dart';
import '../constants/regions.dart';
import 'loading_screen.dart';

class _Question {
  final String id, question;
  final int maxSelect;
  final bool required;
  final List<String> options;
  const _Question({required this.id, required this.question, required this.maxSelect, required this.required, required this.options});
}

const List<_Question> _questions = [
  _Question(id:'Q1', question:'나와 가장 잘 맞는\n성격은?', maxSelect:2, required:true,
    options:['친절하고 사람을 좋아해요','꼼꼼해요','성실하고 책임감 있어요','창의적이에요','자연을 좋아해요']),
  _Question(id:'Q2', question:'가장 끌리는\n일터 장면은?', maxSelect:2, required:true,
    options:['보육, 돌봄','동네 관리 및 청소','가게 운영','음식 만들기','식물 가꾸기','행사 및 문화 돕기','서류 정리','교육 및 상담','카페 및 바리스타']),
  _Question(id:'Q3', question:'하루에 감당할 수 있는\n활동량은?', maxSelect:1, required:true,
    options:['주로 앉아서','가볍게 걷기','야외 활동 가능']),
  _Question(id:'Q4', question:'선호하는 일터\n환경은?', maxSelect:1, required:true,
    options:['실내','실외','상관없음']),
  _Question(id:'Q5', question:'일주일에 몇 일\n근무하기를 원하세요?', maxSelect:1, required:true,
    options:['짧게','4~5일']),
  _Question(id:'Q6', question:'보유 중인\n자격증은?', maxSelect:10, required:false,
    options:['사회복지사 1급/2급 자격증','요양보호사 자격증','한식조리기능사','운전면허','경비원 신임교육 이수']),
];

const int _totalSteps = 8; // Q1~Q6 + Q7 + Q8

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});
  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> with SingleTickerProviderStateMixin {
  int _step = 0;
  final Map<String, dynamic> _answers = {
    'Q1': <String>[], 'Q2': <String>[], 'Q3': '', 'Q4': '', 'Q5': '', 'Q6': <String>[], 'Q7': '', 'Q8': '',
  };

  late final AnimationController _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
  late final Animation<double> _fadeAnim = Tween(begin: 1.0, end: 0.0).animate(_fadeCtrl);
  // _fadeAnim: 1.0(보임) → 0.0(숨김), forward=숨기기, reverse=보이기

  bool get _isQ7 => _step == _questions.length;
  bool get _isQ8 => _step == _questions.length + 1;
  bool get _isLast => _step == _totalSteps - 1;
  _Question? get _q => (!_isQ7 && !_isQ8) ? _questions[_step] : null;

  bool get _answered {
    if (_isQ7) return (_answers['Q7'] as String).isNotEmpty;
    if (_isQ8) return (_answers['Q8'] as String).isNotEmpty;
    final q = _q!;
    if (!q.required) return true;
    if (q.maxSelect == 1) return (_answers[q.id] as String).isNotEmpty;
    return (_answers[q.id] as List<String>).isNotEmpty;
  }

  bool _isSelected(String opt) {
    if (_isQ7) return _answers['Q7'] == opt;
    if (_isQ8) return _answers['Q8'] == opt;
    final q = _q!;
    return q.maxSelect == 1 ? _answers[q.id] == opt : (_answers[q.id] as List<String>).contains(opt);
  }

  void _select(String opt) => setState(() {
    if (_isQ7) { _answers['Q7'] = opt; _answers['Q8'] = ''; return; }
    if (_isQ8) { _answers['Q8'] = opt; return; }
    final q = _q!;
    if (q.maxSelect == 1) { _answers[q.id] = opt; return; }
    final cur = List<String>.from(_answers[q.id] as List<String>);
    cur.contains(opt) ? cur.remove(opt) : (cur.length < q.maxSelect ? cur.add(opt) : null);
    _answers[q.id] = cur;
  });

  void _go(VoidCallback fn) => _fadeCtrl.forward().then((_) { fn(); _fadeCtrl.reverse(); });

  void _next() {
    if (!_answered) return;
    if (_isLast) {
      _go(() => Navigator.push(context, MaterialPageRoute(builder: (_) => LoadingScreen(answers: Map.from(_answers)))));
    } else {
      _go(() => setState(() => _step++));
    }
  }

  void _back() {
    if (_step == 0) { Navigator.pop(context); return; }
    _go(() => setState(() => _step--));
  }

  List<String> get _opts {
    if (_isQ7) return sidoList;
    if (_isQ8) return regions[_answers['Q7']] ?? [];
    return _q?.options ?? [];
  }

  String get _questionText {
    if (_isQ7) return '근무 희망\n지역은 어디인가요?';
    if (_isQ8) return '${_answers['Q7']}\n어느 구/군인가요?';
    return _q?.question ?? '';
  }

  String get _hintText {
    if (_isQ7 || _isQ8) return '1개 선택';
    if (_q?.id == 'Q6') return '없을 시 다음을 눌러주세요';
    return '${_q?.maxSelect}개까지 선택 가능';
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _back(); },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                onTap: _back,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFF5E6D3), borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('←', style: TextStyle(fontFamily:'JalnanGothic', fontSize:24, color:Color(0xFF5C3D2E)))),
                ),
              ),
              Text('${_step + 1} / $_totalSteps', style: const TextStyle(fontFamily:'JalnanGothic', fontSize:18, fontWeight:FontWeight.w700, color:Color(0xFF5C3D2E))),
              const SizedBox(width: 48),
            ]),
          ),
          // 진행 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_step + 1) / _totalSteps,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8D4B8),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFD4A574)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 질문 + 선택지
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(_questionText, style: const TextStyle(fontFamily:'JalnanGothic', fontSize:36, fontWeight:FontWeight.bold, color:Color(0xFF5C3D2E), height:1.4, letterSpacing:-0.5)),
                  const SizedBox(height: 14),
                  Text(_hintText, style: const TextStyle(fontFamily:'JalnanGothic', fontSize:16, fontWeight:FontWeight.w600, color:Color(0xFFEF4444))),
                  const SizedBox(height: 32),
                  ..._opts.map((opt) {
                    final sel = _isSelected(opt);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => _select(opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFD4A574) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: sel ? const Color(0xFFD4A574) : const Color(0xFFE8D4B8), width: 1.5),
                          ),
                          child: Center(child: Text(opt, textAlign: TextAlign.center,
                            style: TextStyle(fontFamily:'JalnanGothic', fontSize:22, fontWeight:FontWeight.bold, color: sel ? Colors.white : const Color(0xFF5C3D2E)))),
                        ),
                      ),
                    );
                  }),
                ]),
              ),
            ),
          ),
          // 다음 버튼
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE8D4B8)))),
            child: SizedBox(
              width: double.infinity, height: 68,
              child: ElevatedButton(
                onPressed: _answered ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answered ? const Color(0xFFD4A574) : const Color(0xFFD4C4B0),
                  foregroundColor: _answered ? Colors.white : const Color(0xFF8B6F47),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFFD4C4B0),
                ),
                child: Text(_isLast ? '결과 보기' : '다음',
                  style: const TextStyle(fontFamily:'JalnanGothic', fontSize:22, fontWeight:FontWeight.bold)),
              ),
            ),
          ),
        ]),
      ),
    ));
  }
}
