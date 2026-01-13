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

enum VerificationStatus { none, pending, verified }

class VerificationNotifier extends StateNotifier<VerificationStatus> {
  VerificationNotifier() : super(VerificationStatus.none) {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('verification_status');
    if (statusString != null) {
      state = VerificationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => VerificationStatus.none,
      );
    }
  }

  Future<void> setStatus(VerificationStatus status) async {
    state = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verification_status', status.toString());
  }
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, VerificationStatus>((ref) {
      return VerificationNotifier();
    });
