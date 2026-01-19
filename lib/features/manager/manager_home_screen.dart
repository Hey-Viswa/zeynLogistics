import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/data/user_model.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/widgets/scale_button.dart';
import '../chat/chat_service.dart';

class ManagerHomeScreen extends ConsumerStatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  ConsumerState<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends ConsumerState<ManagerHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Drivers'),
            Tab(text: 'Chats'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Sign out logic
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVerificationList(context, ref),
          _buildDriverList(context, ref),
          _buildChatList(context, ref),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context, WidgetRef ref) {
    // Import ChatService at top of file needed? No, using ref.read/watch implies provider availability.
    // Need to import chat_service.dart though.
    // I'll assume the import is added or I'll add it in a separate step if needed.
    // Wait, I can't add imports with this tool easily in the same step.
    // I should probably do 'view_file' first to see imports, but I know I haven't added it.
    // I'll implement the widget here and add imports in the next step or careful replacement.

    // Actually, I'll use ref.watch(chatServiceProvider).getActiveChats().
    // But first, let's just put the widget code.
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ref.read(chatServiceProvider).getActiveChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return const Center(child: Text('No active chats'));
        }
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                chat['id'] ?? 'Unknown User',
              ), // In real app, fetch user name using ID
              subtitle: Text(chat['lastMessage'] ?? ''),
              trailing: Text(
                chat['lastMessageTime'] != null
                    ? (chat['lastMessageTime'] as Timestamp)
                          .toDate()
                          .minute
                          .toString() // simplified time
                    : '',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              onTap: () {
                context.push('/chat/${chat['id']}');
              },
            );
          },
        );
      },
    );
  }

  Widget _buildVerificationList(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<UserModel>>(
      stream: ref.read(userRepositoryProvider).getUsersByRole('driver'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final drivers = snapshot.data ?? [];
        final pendingDrivers = drivers
            .where((d) => d.verificationStatus == 'pending')
            .toList();

        if (pendingDrivers.isEmpty) {
          return const Center(child: Text('No pending verifications'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: pendingDrivers.length,
          itemBuilder: (context, index) {
            final driver = pendingDrivers[index];
            return _buildDriverCard(context, driver, isPending: true);
          },
        );
      },
    );
  }

  Widget _buildDriverList(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<UserModel>>(
      stream: ref.read(userRepositoryProvider).getUsersByRole('driver'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final drivers = snapshot.data ?? [];

        if (drivers.isEmpty) {
          return const Center(child: Text('No drivers found'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final driver = drivers[index];
            return _buildDriverCard(context, driver, isPending: false);
          },
        );
      },
    );
  }

  Widget _buildDriverCard(
    BuildContext context,
    UserModel driver, {
    required bool isPending,
  }) {
    return ScaleButton(
      onTap: () {
        context.push('/driver-detail/${driver.id}', extra: driver);
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: driver.photoUrl != null
                    ? NetworkImage(driver.photoUrl!)
                    : null,
                child: driver.photoUrl == null
                    ? Text(driver.name?[0] ?? 'D')
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name ?? 'Unknown Driver',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      driver.phoneNumber,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isPending)
                Chip(
                  label: const Text('Pending'),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
