import 'package:shared_preferences/shared_preferences.dart';

class RoleManager {
  static const _keyRole = 'current_role';

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
  }

  static Future<String> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole) ?? 'Pembeli';
  }
}
