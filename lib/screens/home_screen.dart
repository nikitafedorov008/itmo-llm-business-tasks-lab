import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Персональный ассистент по здоровью'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Добро пожаловать в Персональный ассистент по здоровью!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Наш ассистент поможет вам заботиться о своем здоровье с помощью современных технологий.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.health_and_safety, color: Colors.cyan),
                        title: const Text('Чат с ассистентом'),
                        subtitle: const Text('Задайте вопросы о здоровье, питании и образе жизни'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/chat');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.cyan),
                        title: const Text('Профиль'),
                        subtitle: const Text('Настройте персональные данные'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.notifications, color: Colors.cyan),
                        title: const Text('Напоминания'),
                        subtitle: const Text('Установите напоминания о приеме лекарств и активности'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/reminders');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Основные функции:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildFeatureCard(
                icon: Icons.chat,
                title: 'Чат-ассистент',
                description: 'Общайтесь с AI для получения информации о здоровье и медицине',
              ),
              const SizedBox(height: 10),
              _buildFeatureCard(
                icon: Icons.monitor_heart,
                title: 'Анализ симптомов',
                description: 'Получайте предварительную оценку симптомов с медицинским дисклеймером',
              ),
              const SizedBox(height: 10),
              _buildFeatureCard(
                icon: Icons.local_pharmacy,
                title: 'Напоминания',
                description: 'Установите напоминания о приеме лекарств и медицинских процедурах',
              ),
              const SizedBox(height: 10),
              _buildFeatureCard(
                icon: Icons.history,
                title: 'История',
                description: 'Отслеживайте историю ваших вопросов и рекомендаций',
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Text(
                  'ВАЖНО: Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyan, size: 30),
            const SizedBox(width: 16),
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}