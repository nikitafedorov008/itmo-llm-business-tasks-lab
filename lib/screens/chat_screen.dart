import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/chat_provider.dart';
import '../providers/profile_provider.dart';
import '../services/chatgpt_service.dart';
import '../services/local_storage_service.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadChatHistory();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат с ассистентом'),
        surfaceTintColor: Colors.cyan,
        //backgroundColor: Colors.cyan,
        //foregroundColor: Colors.white,
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
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 128,
        child: _buildInputArea(),
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
                  _buildMessageText(message.text),
                  // Добавляем медицинский дисклеймер только для сообщений от ассистента,
                  // исключая системные команды и системный промпт
                  if (!message.isUser &&
                      !message.text.contains('Вы являетесь персональным ассистентом по здоровью') &&
                      !message.text.startsWith('Доступные команды:') &&
                      !message.text.startsWith('Привет! Я ваш персональный ассистент по здоровью') &&
                      !message.text.startsWith('Для настройки персонального профиля') &&
                      !message.text.startsWith('Для управления напоминаниями') &&
                      !message.text.startsWith('Неизвестная команда'))
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'ВАЖНО: Я не врач. При серьезных симптомах немедленно обратитесь к специалисту.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildMessageText(String text) {
    // Проверяем, содержит ли сообщение команды
    if (text.startsWith('/')) {
      // Если это команда, делаем её жирной и выделяем цветом
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.cyan,
        ),
      );
    }

    // Проверяем, есть ли команды в тексте (например, в списке команд)
    if (text.contains('Доступные команды:') || text.contains('/start') || text.contains('/help')) {
      // Разбиваем текст на части для обработки команд
      return _buildFormattedText(text);
    }

    // Для всех остальных сообщений - используем Markdown для форматирования
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 16),
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        listBullet: const TextStyle(fontSize: 16),
        code: const TextStyle(fontSize: 14, backgroundColor: Colors.grey),
        a: const TextStyle(color: Colors.cyan),
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    if (text.contains('Доступные команды:')) {
      // Разбиваем текст на строки и выделяем команды
      List<String> lines = text.split('\n');
      List<InlineSpan> spans = [];

      for (int i = 0; i < lines.length; i++) {
        String line = lines[i];
        if (i > 0) spans.add(const TextSpan(text: '\n')); // Добавляем перевод строки

        if (line.contains(RegExp(r'\/\w+'))) {
          // Разбиваем строку на части: команды и обычный текст
          final parts = _splitTextByCommands(line);
          spans.addAll(parts);
        } else {
          spans.add(TextSpan(text: line, style: const TextStyle(fontSize: 16)));
        }
      }

      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, height: 1.4),
          children: spans,
        ),
      );
    } else {
      return Text(
        text,
        style: const TextStyle(fontSize: 16),
      );
    }
  }

  List<InlineSpan> _splitTextByCommands(String text) {
    List<InlineSpan> spans = [];
    final commandRegex = RegExp(r'\/\w+');
    final matches = commandRegex.allMatches(text);

    int lastEnd = 0;
    for (Match match in matches) {
      // Добавляем обычный текст до команды
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16),
        ));
      }

      // Добавляем команду с выделением
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.cyan,
        ),
      ));

      lastEnd = match.end;
    }

    // Добавляем оставшийся текст после последней команды
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(fontSize: 16),
      ));
    }

    return spans;
  }

  Widget _buildInputArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Команды подсказки
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              _buildCommandChip('/start', 'Начало'),
              _buildCommandChip('/help', 'Помощь'),
              _buildCommandChip('/profile', 'Профиль'),
              _buildCommandChip('/reminders', 'Напоминания'),
              _buildCommandChip('/add_reminder', 'Напоминание'),
              _buildCommandChip('/list_reminders', 'Список'),
              _buildCommandChip('/bmi', 'ИМТ'),
              _buildCommandChip('/symptoms', 'Симптомы'),
              _buildCommandChip('/diet', 'Питание'),
              _buildCommandChip('/exercise', 'Упражнения'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Поле ввода
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Введите ваш вопрос о здоровью или команду...',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  suffixIcon: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommandChip(String command, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InputChip(
        label: Text(
          command,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        labelStyle: const TextStyle(fontSize: 12),
        avatar: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 10,
          ),
        ),
        onSelected: (bool selected) {
          if (selected) {
            _messageController.text = command;
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _messageController.text.length),
            );
          }
        },
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
    if (command.startsWith('/add_reminder ')) {
      // Обработка команды /add_reminder для добавления напоминания
      String reminderText = command.substring('/add_reminder '.length).trim();
      if (reminderText.isEmpty) {
        chatProvider.addMessage(
          'Пожалуйста, укажите текст напоминания. Пример: /add_reminder Принять лекарство в 14:00',
          false
        );
      } else {
        await _addReminder(reminderText);
        chatProvider.addMessage(
          'Напоминание добавлено: "$reminderText". Для просмотра всех напоминаний используйте /list_reminders или перейдите в раздел "Напоминания".',
          false
        );
      }
      return;
    }

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
          '/add_reminder [текст] - Добавить напоминание\n'
          '/list_reminders - Просмотреть все напоминания\n'
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
      case '/list_reminders':
        await _listReminders(chatProvider);
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
  }

  Future<void> _addReminder(String reminderText) async {
    // Получаем существующие напоминания
    List<Map<String, dynamic>> reminders = await LocalStorageService.getReminders();

    // Создаем новое напоминание
    Map<String, dynamic> newReminder = {
      'title': reminderText,
      'date': DateTime.now().millisecondsSinceEpoch,
      'time': TimeOfDay.now().hour * 60 + TimeOfDay.now().minute,
      'id': DateTime.now().millisecondsSinceEpoch,
    };

    // Добавляем новое напоминание
    reminders.add(newReminder);

    // Сохраняем напоминания
    await LocalStorageService.saveReminders(reminders);
  }

  Future<void> _listReminders(ChatProvider chatProvider) async {
    List<Map<String, dynamic>> reminders = await LocalStorageService.getReminders();

    if (reminders.isEmpty) {
      chatProvider.addMessage('У вас нет установленных напоминаний.', false);
    } else {
      String remindersText = 'Ваши напоминания:\n';
      for (int i = 0; i < reminders.length; i++) {
        remindersText += '${i + 1}. ${reminders[i]['title']}\n';
      }
      chatProvider.addMessage(remindersText, false);
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Недостаточный вес';
    if (bmi < 25) return 'Нормальный вес';
    if (bmi < 30) return 'Избыточный вес';
    return 'Ожирение';
  }
}