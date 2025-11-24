import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatGPTService {
  static String? _apiKey;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    _apiKey = dotenv.env['CHATGPT_API_KEY'];
  }

  static Future<String> getResponse(String message) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return 'Ошибка: API ключ не найден. Пожалуйста, укажите CHATGPT_API_KEY в .env файле.';
    }

    try {
      // Получаем данные профиля из localStorage
      String profileInfo = await _getProfileInfo();

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Вы являетесь персональным ассистентом по здоровью. Отвечайте на вопросы пользователя о здоровье, питании, физических упражнениях и других медицинских темах. ВАЖНО: Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.'
            },
            {
              'role': 'user',
              'content': 'Данные пользователя: $profileInfo\n\nВопрос: $message'
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final completion = data['choices'][0]['message']['content'].toString().trim();
        return completion;
      } else {
        return 'Ошибка при получении ответа от API: ${response.statusCode}';
      }
    } catch (e) {
      log(
        'API Exception',
        name: 'ChatGPTService.getResponse($message)',
        error: e,
      );
      return 'Произошла ошибка при обращении к API: $e';
    }
  }

  static Future<String> _getProfileInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final name = prefs.getString('name') ?? '';
      final age = prefs.getInt('age') ?? 0;
      final gender = prefs.getString('gender') ?? '';
      final weight = prefs.getDouble('weight') ?? 0.0;
      final height = prefs.getDouble('height') ?? 0.0;

      if (name.isEmpty && age == 0 && weight == 0.0 && height == 0.0) {
        return 'Информация о профиле не указана.';
      }

      String profileInfo = 'Имя: $name, ';
      if (age > 0) profileInfo += 'Возраст: $age лет, ';
      if (gender.isNotEmpty) profileInfo += 'Пол: $gender, ';
      if (weight > 0) profileInfo += 'Вес: $weight кг, ';
      if (height > 0) profileInfo += 'Рост: $height см';

      // Убираем последнюю запятую и лишние пробелы
      profileInfo = profileInfo.trim().replaceAll(RegExp(r', $'), '');

      return profileInfo;
    } catch (e) {
      return 'Не удалось получить данные профиля.';
    }
  }
}