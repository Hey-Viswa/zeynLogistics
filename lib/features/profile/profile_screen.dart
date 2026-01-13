import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/role_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data

    // Reset providers if necessary (riverpod auto-dispose handles most)

    if (context.mounted) {
      context.go('/'); // Back to splash/intro
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar & Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      role == UserRole.driver ? 'Driver' : 'Requester',
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
            _buildSectionHeader(context, 'Account Info'),
            const SizedBox(height: 8),
            _buildListTile(
              context,
              icon: Icons.phone,
              title: 'Phone Number',
              subtitle: '+91 98765 43210',
            ),
            _buildListTile(
              context,
              icon: Icons.email,
              title: 'Email',
              subtitle: 'john.doe@example.com',
            ),

            const SizedBox(height: 24),

            // Role Specific Settings
            if (role == UserRole.driver) ...[
              _buildSectionHeader(context, 'Driver Settings'),
              const SizedBox(height: 8),
              _buildListTile(
                context,
                icon: Icons.directions_car,
                title: 'Vehicle Information',
                subtitle: 'Toyota Van (Verified)',
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildListTile(
                context,
                icon: Icons.folder_shared,
                title: 'Documents',
                subtitle: 'Manage uploaded ID & License',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/driver-verification'),
              ),
            ] else ...[
              _buildSectionHeader(context, 'Requester Settings'),
              const SizedBox(height: 8),
              _buildListTile(
                context,
                icon: Icons.bookmark,
                title: 'Saved Places',
                subtitle: 'Home, Work, Gym',
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildListTile(
                context,
                icon: Icons.payment,
                title: 'Payment Methods',
                subtitle: 'Cash, UPI',
                trailing: const Icon(Icons.chevron_right),
              ),
            ],

            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader(context, 'App Settings'),
            const SizedBox(height: 8),
            _buildListTile(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
            _buildListTile(
              context,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'System Default',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manage via System Settings')),
                );
              },
            ),
            _buildListTile(
              context,
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English (India)',
              trailing: const Icon(Icons.chevron_right),
            ),

            const SizedBox(height: 32),

            // Actions
            _buildSectionHeader(context, 'Actions'),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Log Out',
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
}
