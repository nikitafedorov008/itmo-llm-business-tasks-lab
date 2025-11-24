import 'package:flutter/material.dart';
import '../services/chatgpt_service.dart';

class SymptomAnalyzer {
  // Метод для анализа симптомов
  static Future<String> analyzeSymptoms(String symptoms) async {
    final message = "Проанализируй следующие симптомы и предоставь возможные причины: $symptoms. Ответ должен включать в себя рекомендации по обращению к врачу и содержать дисклеймер о том, что это не заменяет профессиональную медицинскую консультацию.";
    return await ChatGPTService.getResponse(message);
  }

  // Метод для получения рекомендаций по симптомам
  static Future<String> getRecommendations(String symptoms) async {
    final message = "На основе следующих симптомов: $symptoms, предоставь рекомендации по образу жизни, диете или активности, которые могут помочь. ВАЖНО: Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.";
    return await ChatGPTService.getResponse(message);
  }
}