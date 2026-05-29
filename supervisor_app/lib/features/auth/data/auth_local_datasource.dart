import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supervisor_app/core/storage/hive_boxes.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) => AuthLocalDataSource());

class AuthLocalDataSource {
  static const _tokenKey = 'jwt_token';
  static const _profileKey = 'supervisor_profile';

  String? getToken() => HiveBoxes.authBox.get(_tokenKey) as String?;

  Future<void> saveToken(String token) async {
    await HiveBoxes.authBox.put(_tokenKey, token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Map<String, dynamic>? getProfile() {
    final data = HiveBoxes.authBox.get(_profileKey);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await HiveBoxes.authBox.put(_profileKey, profile);
  }

  Future<void> clear() async {
    await HiveBoxes.authBox.delete(_tokenKey);
    await HiveBoxes.authBox.delete(_profileKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
