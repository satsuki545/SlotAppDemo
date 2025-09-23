import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/play_history.dart';

class HistoryRepository {
  static const _key = 'play_history_points_v1';

  Future<List<PlayPoint>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(PlayPoint.fromJson).toList();
  }

  Future<void> save(List<PlayPoint> points) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(points.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
