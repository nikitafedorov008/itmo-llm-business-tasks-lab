import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _gender = 'Мужской';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.loadProfile().then((_) {
        _nameController.text = profileProvider.name;
        _ageController.text = profileProvider.age.toString();
        _weightController.text = profileProvider.weight.toString();
        _heightController.text = profileProvider.height.toString();
        setState(() {
          _gender = profileProvider.gender;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль пользователя'),
        surfaceTintColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Личные данные',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Горизонтальный ряд для Имени и Возраста
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите ваше имя';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Возраст',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите ваш возраст';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age <= 0 || age > 150) {
                              return 'Пожалуйста, введите корректный возраст';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Горизонтальный ряд для Веса и Роста
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Вес (кг)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите ваш вес';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0 || weight > 1000) {
                              return 'Пожалуйста, введите корректный вес';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Рост (см)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите ваш рост';
                            }
                            final height = double.tryParse(value);
                            if (height == null || height <= 0 || height > 300) {
                              return 'Пожалуйста, введите корректный рост';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Пол',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('Мужской'),
                  value: 'Мужской',
                  groupValue: _gender,
                  onChanged: (String? value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Женский'),
                  value: 'Женский',
                  groupValue: _gender,
                  onChanged: (String? value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      profileProvider.setProfile(
                        name: _nameController.text,
                        age: int.parse(_ageController.text),
                        gender: _gender,
                        weight: double.parse(_weightController.text),
                        height: double.parse(_heightController.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Профиль успешно сохранен!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Сохранить профиль',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Статистика',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatRow('ИМТ', '${profileProvider.bmi.toStringAsFixed(2)}'),
                            ),
                            Expanded(
                              child: _buildStatRow('Категория', _getBMICategory(profileProvider.bmi)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Недостаточный вес';
    if (bmi < 25) return 'Нормальный вес';
    if (bmi < 30) return 'Избыточный вес';
    return 'Ожирение';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}