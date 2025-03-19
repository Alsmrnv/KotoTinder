import 'package:shared_preferences/shared_preferences.dart';

class LikesStorage {
  static const String _key = 'likes_count';

  static Future<int> getLikesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<void> incrementLikesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_key) ?? 0;
    await prefs.setInt(_key, currentCount + 1);
  }
}
