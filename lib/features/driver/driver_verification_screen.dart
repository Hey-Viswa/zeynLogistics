import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../onboarding/role_provider.dart';

class DriverVerificationScreen extends ConsumerStatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  ConsumerState<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState
    extends ConsumerState<DriverVerificationScreen> {
  final Map<String, bool> _uploadedDocs = {
    'Identity (Aadhar)': false,
    'Driving License': false,
    'Vehicle Registration': false,
    'Insurance Policy': false,
  };

  bool get _isComplete => !_uploadedDocs.values.contains(false);

  Future<void> _uploadDoc(String key) async {
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _uploadedDocs[key] = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$key uploaded successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _uploadedDocs.values.where((e) => e).length;
    final totalCount = _uploadedDocs.length;
    final progress = completedCount / totalCount;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Verify Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Driver Documentation',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload the following documents to verify your identity and vehicle.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount of $totalCount uploaded',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 24),
            // Doc List
            ..._uploadedDocs.keys.map((key) {
              final isUploaded = _uploadedDocs[key]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDocCard(key, isUploaded),
              );
            }),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isComplete
                  ? () {
                      ref
                          .read(verificationProvider.notifier)
                          .setStatus(VerificationStatus.pending);
                      context.go('/verification-pending');
                    }
                  : null, // Disabled until complete
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
              child: const Text('Submit for Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(String title, bool isUploaded) {
    return Card(
      elevation: 0,
      color: isUploaded
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUploaded
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUploaded
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUploaded ? Icons.check : Icons.upload_file,
            color: isUploaded
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isUploaded ? 'Ready for review' : 'Tap to upload',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: isUploaded
            ? null
            : TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _uploadDoc(title);
                },
                child: const Text('Upload'),
              ),
        onTap: isUploaded
            ? null
            : () {
                HapticFeedback.lightImpact();
                _uploadDoc(title);
              },
      ),
    );
  }
}
