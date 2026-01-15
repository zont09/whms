import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whms/configs/app_configs.dart';
import 'package:whms/models/recommend_model.dart';

class RecommendationService {
  // Singleton pattern
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  // Có thể thay đổi base URL khi cần
  String baseUrl = AppConfigs.backend;

  Future<RecommendationResponseModel> recommendEmployees({
    required String title,
    required String description,
    required String type,
    String parent = '',
    int topK = 10,
  }) async {
    final url = Uri.parse('$baseUrl/api/recommendation/recommend');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'type': type,
          'parent': parent,
          'top_k': topK,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return RecommendationResponseModel.fromJson(data);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}