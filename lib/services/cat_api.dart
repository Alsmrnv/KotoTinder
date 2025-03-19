import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cat_info.dart';

class CatService {
  static const String _baseUrl = 'https://api.thecatapi.com/v1';
  static const String _apiKey =
      'live_A2nYRQsgURDsg97FJMdDp8sYKez6Slo1IhlTOnejGhL9UuyY8HcX6MKdHGKkbGrw';

  Future<Cat> fetchRandomCat() async {
    for (int i = 0; i < 5; i++) {
      final response = await http.get(
        Uri.parse('$_baseUrl/images/search?has_breeds=true'),
        headers: {'x-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final catData = data.firstWhere(
          (element) =>
              element['breeds'] != null && element['breeds'].isNotEmpty,
          orElse: () => null,
        );
        if (catData != null) {
          return Cat.fromJson(catData as Map<String, dynamic>);
        }
      } else {
        throw Exception('Ошибка при загрузке данных: ${response.statusCode}');
      }
    }
    throw Exception('Не удалось найти котика');
  }
}
