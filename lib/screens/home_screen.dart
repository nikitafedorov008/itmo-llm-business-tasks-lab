import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.cyan,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        title: const Column(
          children: [
            Text(
              'Персональный ассистент по здоровью',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'поможет заботиться о здоровье с помощью современных технологий',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // Определяем количество колонок в зависимости от ширины экрана
                  int crossAxisCount = 2; // по умолчанию для мобильных
                  if (constraints.maxWidth > 600) {
                    crossAxisCount = 3;
                  }
                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 4;
                  }

                  double cardWidth = (constraints.maxWidth - 20) /
                      crossAxisCount - 10;

                  return Center(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildResponsiveFunctionCard(
                          context,
                          Icons.health_and_safety,
                          'Чат',
                          'Задайте вопросы о здоровье',
                          '/chat',
                          Colors.cyan,
                          cardWidth,
                        ),
                        _buildResponsiveFunctionCard(
                          context,
                          Icons.person,
                          'Профиль',
                          'Персональные данные',
                          '/profile',
                          Colors.green,
                          cardWidth,
                        ),
                        _buildResponsiveFunctionCard(
                          context,
                          Icons.notifications,
                          'Напоминания',
                          'Управление напоминаниями',
                          '/reminders',
                          Colors.orange,
                          cardWidth,
                        ),
                        _buildResponsiveFunctionCard(
                          context,
                          Icons.help,
                          'Справка',
                          'Информация о приложении',
                          '/help',
                          Colors.blue,
                          cardWidth,
                        ),
                      ],
                    ),
                  );
                },
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

  Widget _buildResponsiveFunctionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
    Color color,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}