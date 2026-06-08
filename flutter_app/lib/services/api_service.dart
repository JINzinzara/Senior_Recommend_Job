import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://localhost:3000';

class JobRecommendation {
  final int rank;
  final String title;
  final String jobType;
  final String description;
  final String reason;
  final String link;
  final String contTel;

  JobRecommendation({
    required this.rank,
    required this.title,
    required this.jobType,
    required this.description,
    required this.reason,
    required this.link,
    required this.contTel,
  });

  factory JobRecommendation.fromJson(Map<String, dynamic> json) {
    return JobRecommendation(
      rank: (json['rank'] ?? 0) as int,
      title: json['채용공고명'] ?? '',
      jobType: json['모집직종'] ?? '',
      description: json['모집요강'] ?? '',
      reason: json['reason'] ?? '',
      link: json['링크'] ?? '',
      contTel: json['contTel'] ?? '',
    );
  }
}

class ApiService {
  static Future<List<JobRecommendation>> getRecommendations({
    required List<String> q1,
    required List<String> q2,
    required String q3,
    required String q4,
    required String q5,
    required List<String> q6,
    required String q7,
    required String q8,
  }) async {
    final url = Uri.parse('$_baseUrl/api/trpc/jobs.recommend');

    final body = jsonEncode({
      'json': {
        'Q1': q1,
        'Q2': q2,
        'Q3': q3,
        'Q4': q4,
        'Q5': q5,
        'Q6': q6,
        'Q7': q7,
        'Q8': q8,
      }
    });

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final result = decoded['result']?['data']?['json'];
    if (result == null) throw Exception('응답 형식 오류');

    final List<dynamic> recs = result['recommendations'] ?? [];
    return recs.map((e) => JobRecommendation.fromJson(e)).toList();
  }
}
