import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  String _name = '';
  int _age = 0;
  String _gender = 'Мужской';
  double _weight = 0.0;
  double _height = 0.0;

  String get name => _name;
  int get age => _age;
  String get gender => _gender;
  double get weight => _weight;
  double get height => _height;

  double get bmi => _height > 0 ? _weight / ((_height / 100) * (_height / 100)) : 0;

  Future<void> setProfile({
    required String name,
    required int age,
    required String gender,
    required double weight,
    required double height,
  }) async {
    _name = name;
    _age = age;
    _gender = gender;
    _weight = weight;
    _height = height;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setInt('age', age);
    await prefs.setString('gender', gender);
    await prefs.setDouble('weight', weight);
    await prefs.setDouble('height', height);

    notifyListeners();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _age = prefs.getInt('age') ?? 0;
    _gender = prefs.getString('gender') ?? 'Мужской';
    _weight = prefs.getDouble('weight') ?? 0.0;
    _height = prefs.getDouble('height') ?? 0.0;

    notifyListeners();
  }
}