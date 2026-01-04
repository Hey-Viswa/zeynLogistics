import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { driver, requester, none }

class RoleNotifier extends StateNotifier<UserRole> {
  RoleNotifier() : super(UserRole.none) {
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role');
    if (roleString != null) {
      state = UserRole.values.firstWhere(
        (e) => e.toString() == roleString,
        orElse: () => UserRole.none,
      );
    }
  }

  Future<void> setRole(UserRole role) async {
    state = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.toString());
  }

  Future<void> clearRole() async {
    state = UserRole.none;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
  }
}

final roleProvider = StateNotifierProvider<RoleNotifier, UserRole>((ref) {
  return RoleNotifier();
});
