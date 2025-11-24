import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/profile_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/help_screen.dart';
import 'screens/reminders_screen.dart';

void main() async {
  // Инициализация .env файла
  await dotenv.load(fileName: ".env");
  runApp(const HealthAssistantApp());
}

class HealthAssistantApp extends StatelessWidget {
  const HealthAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Персональный ассистент по здоровью',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/chat': (context) => const ChatScreen(),
          '/help': (context) => const HelpScreen(),
          '/reminders': (context) => const RemindersScreen(),
        },
      ),
    );
  }
}