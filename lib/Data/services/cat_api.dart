import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cat_info.dart';
import '../../Domain/services/cat_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CatApiService implements CatService {
  static const String _url =
      'https://api.thecatapi.com/v1/images/search?has_breeds=1';
  final apiKey = dotenv.env['API_KEY'];

  @override
  Future<Cat> fetchRandomCat() async {
    final response = await http.get(
      Uri.parse(_url),
      headers: {'x-api-key': apiKey ?? ''},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final catData = data.firstWhere(
        (element) => element['breeds'] != null && element['breeds'].isNotEmpty,
        orElse: () => null,
      );
      if (catData != null) {
        return Cat.fromJson(catData as Map<String, dynamic>);
      }
    } else {
      throw Exception('Error loading data: ${response.statusCode}');
    }

    throw Exception("Couldn't find the cat");
  }
}
