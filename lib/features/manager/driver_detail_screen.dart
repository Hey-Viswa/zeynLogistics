import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/data/user_model.dart';
import '../../shared/services/user_repository.dart';

class DriverDetailScreen extends ConsumerStatefulWidget {
  final UserModel driver;

  const DriverDetailScreen({super.key, required this.driver});

  @override
  ConsumerState<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends ConsumerState<DriverDetailScreen> {
  // We can update the local user model if we want immediate feedback,
  // but better to rely on the stream/latest data.
  // We'll trust the passed 'driver' for initial render and update via repository.

  Future<void> _updateStatus(String status) async {
    final isVerified = status == 'verified';
    try {
      await ref.read(userRepositoryProvider).updateUser(widget.driver.id, {
        'verificationStatus': status,
        'isVerified': isVerified,
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Driver marked as $status')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Documents list
    final docs = widget.driver.documents;

    return Scaffold(
      appBar: AppBar(title: Text(widget.driver.name ?? 'Driver Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Info
            _buildInfoCard(context),
            SizedBox(height: 24.h),
            Text('Documents', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16.h),
            if (docs.isEmpty)
              const Text('No documents uploaded.')
            else
              ...docs.entries.map((e) => _buildDocItem(e.key, e.value)),
            SizedBox(height: 32.h),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus('rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _updateStatus('verified'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundImage: widget.driver.photoUrl != null
                  ? NetworkImage(widget.driver.photoUrl!)
                  : null,
              child: widget.driver.photoUrl == null
                  ? Text(widget.driver.name?[0] ?? 'D')
                  : null,
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driver.name ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  widget.driver.phoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Status: ${widget.driver.verificationStatus ?? 'Pending'}',
                  style: TextStyle(
                    color: _getStatusColor(widget.driver.verificationStatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocItem(String name, String url) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: const Icon(Icons.file_present),
        title: Text(name),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          // Open URL (In a real app, use url_launcher or a webview)
          // For now, just show a dialog with the image if it's an image
          showDialog(
            context: context,
            builder: (context) => Dialog(child: Image.network(url)),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
