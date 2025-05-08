import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Data/models/cat_info.dart';

class LikedCatsStorage {
  static const String _key = 'liked_cats';

  static Future<void> saveLikedCats(List<Cat> cats) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> catsMapList =
        cats.map((cat) {
          return {
            'imageUrl': cat.imageUrl,
            'likedAt': cat.likedAt.toIso8601String(),
            'breed': {
              'name': cat.breed.name,
              'description': cat.breed.description,
              'origin': cat.breed.origin,
              'temperament': cat.breed.temperament,
              'lifeSpan': cat.breed.lifeSpan,
              'grooming': cat.breed.grooming,
            },
          };
        }).toList();

    await prefs.setString(_key, jsonEncode(catsMapList));
  }

  static Future<List<Cat>> getLikedCats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? catsJson = prefs.getString(_key);

    if (catsJson == null || catsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(catsJson);
      return decodedList.map((json) {
        return Cat(
          imageUrl: json['imageUrl'] as String,
          likedAt: DateTime.parse(json['likedAt'] as String),
          breed: Breed(
            name: json['breed']['name'] as String,
            description: json['breed']['description'] as String,
            origin: json['breed']['origin'] as String,
            temperament: json['breed']['temperament'] as String,
            lifeSpan: json['breed']['lifeSpan'] as String,
            grooming: json['breed']['grooming'] as int,
          ),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
