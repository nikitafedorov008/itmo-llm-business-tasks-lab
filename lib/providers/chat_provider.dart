import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chatgpt_service.dart';
import 'package:langchain/langchain.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  static const String _chatHistoryKey = 'chat_history';

  List<Message> get messages => _messages;

  void addMessage(String text, bool isUser) {
    _messages.add(Message(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    _saveChatHistory();
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _saveChatHistory();
    ChatGPTService.clearConversationHistory(); // Очищаем историю в сервисе тоже
    notifyListeners();
  }

  Future<void> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistoryJson = prefs.getStringList(_chatHistoryKey) ?? [];

    _messages = chatHistoryJson
        .map((json) => Message.fromJson(Map<String, dynamic>.from(jsonDecode(json))))
        .toList();

    // Восстанавливаем историю в ChatGPTService
    List<ChatMessage> serviceHistory = [];
    for (Message message in _messages) {
      if (message.isUser) {
        serviceHistory.add(HumanChatMessage(content: ChatMessageContent.text(message.text)));
      } else {
        serviceHistory.add(AIChatMessage(content: message.text));
      }
    }
    ChatGPTService.setConversationHistory(serviceHistory);

    notifyListeners();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistoryJson = _messages.map((message) => jsonEncode(message.toJson())).toList();
    await prefs.setStringList(_chatHistoryKey, chatHistoryJson);
  }

  // Метод для преобразования истории сообщений в формат, подходящий для ChatGPTService
  void syncWithService() {
    List<ChatMessage> serviceHistory = [];
    for (Message message in _messages) {
      if (message.isUser) {
        serviceHistory.add(
          HumanChatMessage(
            content: ChatMessageContent.text(message.text),
          ),
        );
      } else {
        serviceHistory.add(AIChatMessage(content: message.text));
      }
    }
    ChatGPTService.setConversationHistory(serviceHistory);
  }
}