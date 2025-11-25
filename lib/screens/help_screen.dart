import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справка'),
        surfaceTintColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Персональный ассистент по здоровью',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Добро пожаловать в справочный центр нашего ассистента по здоровью.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              _buildHelpSection(
                title: 'Как использовать приложение',
                content: [
                  '1. Заполните ваш профиль с персональными данными (имя, возраст, вес, рост)',
                  '2. Используйте чат для задания вопросов о здоровье',
                  '3. Установите напоминания о приеме лекарств или активности',
                  '4. Просматривайте историю ваших вопросов и ответов'
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                title: 'Возможности приложения',
                content: [
                  '• Чат с AI-ассистентом для вопросов о здоровье',
                  '• Анализ симптомов с медицинским дисклеймером',
                  '• Персональный профиль с рассчетом ИМТ',
                  '• Система напоминаний о приеме лекарств',
                  '• История ваших вопросов к ассистенту'
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                title: 'Важные замечания',
                content: [
                  '• Все медицинские консультации носят рекомендательный характер',
                  '• При серьезных симптомах всегда обращайтесь к врачу',
                  '• Приложение не заменяет профессиональную медицинскую помощь',
                  '• Все данные хранятся локально на вашем устройстве'
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ВАЖНО:',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection({required String title, required List<String> content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...content.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 15))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}