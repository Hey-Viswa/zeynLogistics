import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../onboarding/role_provider.dart';
import '../../shared/theme/theme_provider.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/data/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) context.go('/intro');
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    // Show Source Selector
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    // Compress image to ensure it fits in Firestore document (< 1MB)
    final image = await picker.pickImage(
      source: source,
      maxWidth: 600,
      imageQuality: 50,
    );

    if (image != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing image...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final url = await ref
          .read(storageServiceProvider)
          .uploadProfileImage(uid, image);
      if (url != null) {
        await ref.read(userRepositoryProvider).updateUser(uid, {
          'photoUrl': url,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process image.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  ImageProvider? _getProfileImage(String? photoUrl) {
    if (photoUrl == null) return null;
    if (photoUrl.startsWith('http')) {
      return CachedNetworkImageProvider(photoUrl);
    }
    try {
      return MemoryImage(base64Decode(photoUrl));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current User ID
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userAsync = ref.watch(userStreamProvider(user.uid));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('profile.title'.tr()), centerTitle: true),
      body: userAsync.when(
        data: (userData) {
          if (userData == null)
            return const Center(child: Text('User not found'));
          final role = userData.role == 'driver'
              ? UserRole.driver
              : UserRole.requester;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar & Name
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _pickAndUploadImage(context, ref, userData.id),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _getProfileImage(userData.photoUrl),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: userData.photoUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData.name ?? 'Guest',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          role == UserRole.driver
                              ? 'profile.driver'.tr()
                              : 'profile.requester'.tr(),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account Section
                _buildSectionHeader(context, 'profile.account_info'.tr()),
                const SizedBox(height: 8),
                _buildListTile(
                  context,
                  icon: Icons.phone,
                  title: 'profile.phone'.tr(),
                  subtitle: userData.phoneNumber.isNotEmpty
                      ? userData.phoneNumber
                      : 'Not set',
                  trailing: Icon(
                    Icons.edit,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => context.push('/edit-profile', extra: userData),
                ),
                _buildListTile(
                  context,
                  icon: Icons.email,
                  title: 'profile.email'.tr(),
                  subtitle: userData.email ?? 'Not set',
                  onTap: () => context.push('/edit-profile', extra: userData),
                ),

                const SizedBox(height: 24),

                // Role Specific Settings
                if (role == UserRole.driver) ...[
                  _buildSectionHeader(context, 'profile.driver_settings'.tr()),
                  const SizedBox(height: 8),
                  _buildListTile(
                    context,
                    icon: Icons.directions_car,
                    title: 'profile.vehicle_info'.tr(),
                    subtitle: 'Toyota Van (Verified)', // Placeholder
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.folder_shared,
                    title: 'profile.documents'.tr(),
                    subtitle: 'Manage uploaded ID & License',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/driver-verification'),
                  ),
                ] else ...[
                  _buildSectionHeader(
                    context,
                    'profile.requester_settings'.tr(),
                  ),
                  const SizedBox(height: 8),
                  _buildListTile(
                    context,
                    icon: Icons.bookmark,
                    title: 'profile.saved_places'.tr(),
                    subtitle: '${userData.savedPlaces.length} places',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/saved-places', extra: userData),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.bookmark,
                    title: 'profile.saved_places'.tr(),
                    subtitle: '${userData.savedPlaces.length} places',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/saved-places', extra: userData),
                  ),
                ],

                const SizedBox(height: 24),

                // Settings Section
                _buildSectionHeader(context, 'profile.app_settings'.tr()),
                const SizedBox(height: 8),
                _buildListTile(
                  context,
                  icon: Icons.notifications,
                  title: 'profile.notifications'.tr(),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                _buildListTile(
                  context,
                  icon: Icons.dark_mode,
                  title: 'profile.app_theme'.tr(),
                  subtitle: ref.watch(themeProvider).name.toUpperCase(),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemePicker(context, ref),
                ),
                _buildListTile(
                  context,
                  icon: Icons.language,
                  title: 'profile.language'.tr(),
                  subtitle: context.locale.languageCode.toUpperCase(),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePicker(context),
                ),
                _buildListTile(
                  context,
                  icon: Icons.swap_horiz_rounded,
                  title: 'Switch Role',
                  subtitle: role == UserRole.driver
                      ? 'Switch to Rider'
                      : 'Switch to Driver',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showSwitchRoleDialog(context, ref, role, userData.id),
                ),

                const SizedBox(height: 32),

                // Actions
                _buildSectionHeader(context, 'profile.actions'.tr()),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'profile.logout'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _logout(context, ref),
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Version 1.0.0 (Build 12)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildThemeOption(context, ref, 'System Default', ThemeMode.system),
            _buildThemeOption(context, ref, 'Light Mode', ThemeMode.light),
            _buildThemeOption(context, ref, 'Dark Mode', ThemeMode.dark),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    ThemeMode mode,
  ) {
    final currentMode = ref.watch(themeProvider);
    return ListTile(
      title: Text(title),
      trailing: currentMode == mode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(mode);
        context.pop();
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, 'English', const Locale('en')),
            _buildLanguageOption(context, 'Hindi', const Locale('hi')),
            _buildLanguageOption(context, 'Urdu', const Locale('ur')),
            _buildLanguageOption(context, 'Arabic', const Locale('ar')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    Locale locale,
  ) {
    final currentLocale = context.locale;
    return ListTile(
      title: Text(title),
      trailing: currentLocale == locale
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        context.setLocale(locale);
        context.pop();
      },
    );
  }

  Future<void> _showSwitchRoleDialog(
    BuildContext context,
    WidgetRef ref,
    UserRole currentRole,
    String uid,
  ) async {
    final targetRole = currentRole == UserRole.driver
        ? UserRole.requester
        : UserRole.driver;
    final targetRoleString = targetRole == UserRole.driver ? 'Driver' : 'Rider';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to $targetRoleString?'),
        content: Text(
          'You are currently using the app as a ${currentRole == UserRole.driver ? "Driver" : "Rider"}.\n\n'
          'Switching will change your dashboard and features. Your data will be safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Switch to $targetRoleString'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Switching role...')));
      }

      await ref.read(userRepositoryProvider).updateUser(uid, {
        'role': targetRole == UserRole.driver ? 'driver' : 'requester',
      });

      await ref.read(roleProvider.notifier).setRole(targetRole);

      if (context.mounted) {
        context.go('/home');
      }
    }
  }
}
