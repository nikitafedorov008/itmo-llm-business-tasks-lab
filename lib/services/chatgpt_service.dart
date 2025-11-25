import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class ChatGPTService {
  static ChatOpenAI? _chat;
  static List<ChatMessage> _conversationHistory = [];

  static Future<void> initialize() async {
    late String? apiKey;
    try {
      apiKey = const String.fromEnvironment('CHATGPT_API_KEY');
    } catch (e) {
      log(
        'dart define fetch exception',
        name: 'ChatGPTService.initialize()',
        error: e,
      );
      await dotenv.load(fileName: '.env');
      apiKey = dotenv.env['CHATGPT_API_KEY'];
    }

    if (apiKey != null && apiKey.isNotEmpty) {
      _chat = ChatOpenAI(
        apiKey: apiKey,
        baseUrl: 'https://api.proxyapi.ru/openai/v1',
        defaultOptions: const ChatOpenAIOptions(
          model: 'gpt-5-mini',
        ),
      );
    }
  }

  static Future<String> getResponse(String message) async {
    if (_chat == null) {
      return 'Ошибка: API ключ не найден. Пожалуйста, укажите CHATGPT_API_KEY в .env файле.';
    }

    try {
      // Добавляем сообщение пользователя в историю
      _conversationHistory.add(
        HumanChatMessage(
          content: ChatMessageContent.text(message),
        ),
      );

      // Получаем данные профиля из localStorage
      String profileInfo = await _getProfileInfo();

      // Формируем системное сообщение с информацией о пользователе
      final systemMessage = SystemChatMessage(content: '''Вы являетесь персональным ассистентом по здоровью. Отвечайте на вопросы пользователя о здоровье, питании, физических упражнениях и других медицинских темах. ВАЖНО: Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.
      Информация должна предоставляться в формате markdown.

Данные пользователя: $profileInfo''');

      // Собираем все сообщения: системное + история разговора
      final messages = <ChatMessage>[
        systemMessage,
        ..._conversationHistory,
      ];

      final result = await _chat!.call(messages);

      // Добавляем ответ ассистента в историю
      _conversationHistory.add(AIChatMessage(content: result.content.toString()));

      return result.content.toString();
    } catch (e) {
      log(
        'API Exception. Используем тестовый ответ для демонстрации.',
        name: 'ChatGPTService.getResponse($message)',
        error: e,
      );
      // Возвращаем тестовый ответ для веб-демонстрации из-за CORS ограничений
      return _getDemoResponse(message);
    }
  }

  static String _getDemoResponse(String userMessage) {
    // Простая логика для генерации демонстрационных ответов
    if (userMessage.toLowerCase().contains('привет') || userMessage.toLowerCase().contains('здравствуй')) {
      return 'Привет! Я ваш персональный ассистент по здоровью. Как я могу вам помочь сегодня? Помните, что я не врач, и при серьезных симптомах нужно обратиться к специалисту.';
    } else if (userMessage.toLowerCase().contains('как дела') || userMessage.toLowerCase().contains('как себя чувствовать')) {
      return 'Я - виртуальный ассистент, у меня нет чувств, но я всегда готов помочь вам с вопросами о здоровье! Важно поддерживать сбалансированное питание, регулярную физическую активность и достаточный сон для хорошего самочувствия.';
    } else if (userMessage.toLowerCase().contains('диета') || userMessage.toLowerCase().contains('питание')) {
      return 'Сбалансированное питание - ключ к здоровью! Старайтесь употреблять больше овощей, фруктов, цельнозерновых продуктов и белков. Избегайте излишка сахара, соли и насыщенных жиров. При индивидуальных потребностях проконсультируйтесь с диетологом.';
    } else if (userMessage.toLowerCase().contains('упражнения') || userMessage.toLowerCase().contains('спорт')) {
      return 'Регулярные физические упражнения важны для здоровья сердца, мышц и психического состояния. Рекомендуется как минимум 150 минут умеренной активности в неделю. Начинайте с малого и постепенно увеличивайте нагрузку.';
    } else if (userMessage.toLowerCase().contains('голова') || userMessage.toLowerCase().contains('боль')) {
      return 'При частых или сильных головных болях необходимо обратиться к врачу. Временно может помочь отдых в тихой и темной комнате, достаточное количество воды и, при необходимости, безрецептурные обезболивающие средства (по инструкции).';
    } else {
      return 'Спасибо за ваш вопрос: "$userMessage". В реальном приложении я бы передал его в OpenAI API и получил профессиональный ответ. Пожалуйста, помните, что я не врач. При серьезных симптомах немедленно обратитесь к специалисту.';
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

  // Методы для работы с историей разговора
  static List<ChatMessage> getConversationHistory() => _conversationHistory;

  static void clearConversationHistory() {
    _conversationHistory.clear();
  }

  static void setConversationHistory(List<ChatMessage> history) {
    _conversationHistory = history;
  }
}