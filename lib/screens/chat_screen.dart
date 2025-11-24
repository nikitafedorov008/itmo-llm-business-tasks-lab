import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/profile_provider.dart';
import '../services/chatgpt_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    ChatGPTService.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат с ассистентом'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return _buildMessage(message);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.cyan.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: message.isUser ? Colors.cyan.shade700 : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Введите ваш вопрос о здоровье или команду (/start, /help, /profile)...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: Colors.cyan,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Добавляем сообщение пользователя
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addMessage(text, true);
    _messageController.clear();

    // Прокручиваем к последнему сообщению
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Проверяем, является ли сообщение командой
    if (text.startsWith('/')) {
      await _handleCommand(text, chatProvider);
    } else {
      // Получаем ответ от ChatGPT
      final response = await ChatGPTService.getResponse(text);

      // Добавляем ответ ассистента
      chatProvider.addMessage(response, false);

      // Добавляем медицинский дисклеймер
      chatProvider.addMessage(
        'ВАЖНО: Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.',
        false
      );
    }

    // Прокручиваем к последнему сообщению
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleCommand(String command, ChatProvider chatProvider) async {
    switch (command) {
      case '/start':
        chatProvider.addMessage(
          'Привет! Я ваш персональный ассистент по здоровью.\n\n'
          'Я могу помочь вам с:\n'
          '• Ответами на вопросы о здоровье и медицине\n'
          '• Анализом симптомов (с медицинским дисклеймером)\n'
          '• Установкой напоминаний о приеме лекарств\n'
          '• Отслеживанием вашего профиля здоровья\n\n'
          'Для получения справки по командам используйте /help',
          false
        );
        break;
      case '/help':
        chatProvider.addMessage(
          'Доступные команды:\n'
          '/start - Приветствие и описание возможностей\n'
          '/help - Справка по всем командам\n'
          '/profile - Настройка персонального профиля\n'
          '/symptoms - Анализ симптомов\n'
          '/reminders - Управление напоминаниями\n'
          '/bmi - Рассчет индекса массы тела\n'
          '/diet - Рекомендации по диете\n'
          '/exercise - Рекомендации по физическим упражнениям\n\n'
          'Вы также можете задавать любые вопросы о здоровье в обычном формате.',
          false
        );
        break;
      case '/profile':
        chatProvider.addMessage(
          'Для настройки персонального профиля перейдите на вкладку "Профиль" в главном меню.\n\n'
          'В профиле вы можете указать:\n'
          '• Имя\n'
          '• Возраст\n'
          '• Пол\n'
          '• Вес (в кг)\n'
          '• Рост (в см)\n\n'
          'Эти данные помогут мне давать более персонализированные рекомендации.',
          false
        );
        break;
      case '/symptoms':
        chatProvider.addMessage(
          'Опишите ваши симптомы, и я постараюсь дать предварительную оценку.\n\n'
          'Например: "У меня болит голова и повышена температура последние 3 дня"',
          false
        );
        break;
      case '/reminders':
        chatProvider.addMessage(
          'Для управления напоминаниями перейдите на вкладку "Напоминания" в главном меню.\n\n'
          'Там вы можете:\n'
          '• Добавить новые напоминания\n'
          '• Удалить существующие\n'
          '• Просмотреть все установленные напоминания',
          false
        );
        break;
      case '/bmi':
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.loadProfile();
        if (profileProvider.height > 0) {
          final bmi = profileProvider.bmi;
          String bmiCategory = _getBMICategory(bmi);
          chatProvider.addMessage(
            'Ваш индекс массы тела (ИМТ): ${bmi.toStringAsFixed(2)}\n'
            'Категория: $bmiCategory\n\n'
            'ИМТ - это показатель соотношения веса и роста. '
            'Однако он не учитывает мышечную массу и другие факторы. '
            'При необходимости обратитесь к врачу для более точной оценки.',
            false
          );
        } else {
          chatProvider.addMessage(
            'Для рассчета ИМТ необходимо заполнить данные о росте и весе в профиле. '
            'Перейдите в раздел "Профиль" для настройки персональных данных.',
            false
          );
        }
        break;
      case '/diet':
        chatProvider.addMessage(
          'Для получения рекомендаций по питанию укажите, пожалуйста, вашу цель (похудение, набор массы, поддержание формы) '
          'и любые ограничения (аллергии, предпочтения и т.д.).',
          false
        );
        break;
      case '/exercise':
        chatProvider.addMessage(
          'Для получения рекомендаций по физическим упражнениям укажите, пожалуйста, ваш уровень физической подготовки '
          'и цели (укрепление здоровья, похудение, набор мышечной массы).',
          false
        );
        break;
      default:
        chatProvider.addMessage(
          'Неизвестная команда. Для получения справки используйте /help',
          false
        );
        break;
    }

    // Добавляем медицинский дисклеймер для команд, кроме /help и /start
    if (command != '/help' && command != '/start') {
      chatProvider.addMessage(
        'ВАЖНО: Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.',
        false
      );
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Недостаточный вес';
    if (bmi < 25) return 'Нормальный вес';
    if (bmi < 30) return 'Избыточный вес';
    return 'Ожирение';
  }
}