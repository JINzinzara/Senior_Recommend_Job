import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../constants/app_theme.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<JobRecommendation> recommendations;
  const ResultScreen({super.key, required this.recommendations});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final PageController _pageCtrl = PageController(viewportFraction: 0.88);
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = widget.recommendations;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        // 배경 꽃 이미지 (5%)
        Positioned.fill(child: Image.asset(AppTheme.flowerBg,
            fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.05))),
        SafeArea(
        child: Column(children: [
          // ── 헤더 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('추천 일자리',
                  style: TextStyle(
                      fontFamily: 'JalnanGothic',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark)),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false),
                child: const Text('처음으로',
                    style: TextStyle(
                        fontFamily: 'JalnanGothic',
                        fontSize: 16,
                        color: AppTheme.primary)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '적합한 ${jobs.length}개의 공고를 추천했어요',
                style: const TextStyle(
                    fontFamily: 'JalnanGothic',
                    fontSize: 16,
                    color: AppTheme.textMid),
              ),
            ),
          ),

          // ── 카드 슬라이더 ──
          Expanded(
            child: jobs.isEmpty
                ? _buildEmpty(context)
                : Column(children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageCtrl,
                        itemCount: jobs.length,
                        onPageChanged: (i) => setState(() => _current = i),
                        itemBuilder: (_, i) => AnimatedScale(
                          scale: _current == i ? 1.0 : 0.94,
                          duration: const Duration(milliseconds: 250),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: _JobCard(job: jobs[i], rank: i + 1),
                          ),
                        ),
                      ),
                    ),
                    // ── 페이지 인디케이터 ──
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(jobs.length, (i) {
                          final active = i == _current;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.primary
                                  : AppTheme.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ]),
          ),
        ]),
        ),  // SafeArea
      ]),  // Stack
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off_rounded,
              size: 72, color: AppTheme.primary),
          const SizedBox(height: 24),
          const Text('추천 공고를 찾지 못했어요',
              style: TextStyle(
                  fontFamily: 'JalnanGothic',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          const Text('지역을 변경하거나 다시 시도해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'JalnanGothic',
                  fontSize: 16,
                  color: AppTheme.textMid)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16)),
            child: const Text('처음으로 돌아가기',
                style: TextStyle(
                    fontFamily: 'JalnanGothic',
                    fontSize: 18,
                    color: Colors.white)),
          ),
        ]),
      );
}

// ── 카드 위젯 ──────────────────────────────────────────────────
class _JobCard extends StatefulWidget {
  final JobRecommendation job;
  final int rank;
  const _JobCard({required this.job, required this.rank});
  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _expanded = false;

  void _apply() {
    final tel = widget.job.contTel;
    final link = widget.job.link;
    if (tel.isNotEmpty) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                title: const Text('지원 방법 선택',
                    style: TextStyle(
                        fontFamily: 'JalnanGothic',
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
                content: Text(tel,
                    style: const TextStyle(
                        fontFamily: 'JalnanGothic',
                        fontSize: 16,
                        color: AppTheme.textMid)),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                actions: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          launchUrl(Uri.parse(
                              'tel:${tel.replaceAll(RegExp(r'[^0-9]'), '')}'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('📞  전화하기',
                            style: TextStyle(
                                fontFamily: 'JalnanGothic',
                                fontSize: 22,
                                color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          launchUrl(Uri.parse(
                              'sms:${tel.replaceAll(RegExp(r'[^0-9]'), '')}'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5E6D3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('💬  문자 보내기',
                            style: TextStyle(
                                fontFamily: 'JalnanGothic',
                                fontSize: 22,
                                color: AppTheme.textDark)),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('취소',
                            style: TextStyle(
                                fontFamily: 'JalnanGothic',
                                fontSize: 18,
                                color: AppTheme.textMid)),
                      ),
                    ],
                  ),
                ],
              ));
    } else if (link.isNotEmpty) {
      launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final hasTel = job.contTel.isNotEmpty;
    final hasLink = job.link.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 순위 + 제목
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${widget.rank}위',
                  style: const TextStyle(
                      fontFamily: 'JalnanGothic',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(job.title,
                  style: const TextStyle(
                      fontFamily: 'JalnanGothic',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      height: 1.3)),
            ),
          ]),
          const SizedBox(height: 10),
          // 직종 태그
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(8)),
            child: Text(job.jobType,
                style: const TextStyle(
                    fontFamily: 'JalnanGothic',
                    fontSize: 14,
                    color: AppTheme.textMid,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 14),
          // 추천 이유
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text('💡 ${job.reason}',
                style: const TextStyle(
                    fontFamily: 'JalnanGothic',
                    fontSize: 15,
                    color: AppTheme.textDark,
                    height: 1.5)),
          ),
          const SizedBox(height: 12),
          // 모집요강 펼치기
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(children: [
              const Text('모집 요강',
                  style: TextStyle(
                      fontFamily: 'JalnanGothic',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMid)),
              const SizedBox(width: 4),
              Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.textMid,
                  size: 18),
            ]),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            Text(job.description,
                style: const TextStyle(
                    fontFamily: 'JalnanGothic',
                    fontSize: 14,
                    color: AppTheme.textMid,
                    height: 1.6)),
            const SizedBox(height: 12),
          ],
          // 지원 버튼
          if (hasTel || hasLink) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                child: Text(hasTel ? '📞 지원하기' : '📋 공고 보기',
                    style: const TextStyle(
                        fontFamily: 'JalnanGothic',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
