import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _remindersKey = 'reminders';

  static Future<void> saveReminders(List<Map<String, dynamic>> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = reminders.map((reminder) => json.encode(reminder)).toList();
    await prefs.setStringList(_remindersKey, remindersJson);
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey) ?? [];
    return remindersJson.map<Map<String, dynamic>>((json) => jsonDecode(json)).toList();
  }
}