import 'package:flutter/material.dart';
import 'survey_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A574),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(Icons.work_outline_rounded, size: 56, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        '시니어 일자리\n추천 서비스',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JalnanGothic',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '간단한 설문으로\n나에게 딱 맞는 일자리를 찾아보세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JalnanGothic',
                          fontSize: 18,
                          color: Color(0xFF8B6F47),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SurveyScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A574),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '찾기',
                    style: TextStyle(fontFamily: 'JalnanGothic', fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
