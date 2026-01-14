import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:image_picker/image_picker.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/services/auth_service.dart';
import '../onboarding/role_provider.dart';

class DriverVerificationScreen extends ConsumerStatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  ConsumerState<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState
    extends ConsumerState<DriverVerificationScreen> {
  bool _isUploading = false;

  // Track the actual URLs of uploaded documents
  final Map<String, String?> _documentUrls = {
    'Identity (Aadhar)': null,
    'Driving License': null,
    'Vehicle Registration': null,
    'Insurance Policy': null,
  };

  bool get _isComplete => !_documentUrls.values.contains(null);

  Future<void> _uploadDoc(String key) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Upload to Storage
      final url = await ref
          .read(storageServiceProvider)
          .uploadDriverDocument(user.uid, key, image);

      if (url != null) {
        setState(() {
          _documentUrls[key] = url;
        });

        // 2. Update Firestore
        // We filter out nulls to pass a valid Map<String, String>
        final validDocs = Map<String, String>.fromEntries(
          _documentUrls.entries
              .where((e) => e.value != null)
              .map((e) => MapEntry(e.key, e.value!)),
        );

        await ref
            .read(userRepositoryProvider)
            .updateUserDocuments(user.uid, validDocs);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$key uploaded successfully')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress based on non-null URLs
    final completedCount = _documentUrls.values.where((e) => e != null).length;
    final totalCount = _documentUrls.length;
    final progress = completedCount / totalCount;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Verify Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Driver Documentation',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Upload the following documents to verify your identity and vehicle.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 32.h),
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '$completedCount of $totalCount uploaded',
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontSize: 12.sp),
            ),
            SizedBox(height: 24.h),
            // Doc List
            if (_isUploading) const LinearProgressIndicator(),
            ..._documentUrls.keys.map((key) {
              final isUploaded = _documentUrls[key] != null;
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildDocCard(key, isUploaded),
              );
            }),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: _isComplete
                  ? () {
                      ref
                          .read(verificationProvider.notifier)
                          .setStatus(VerificationStatus.pending);
                      context.go('/verification-pending');
                    }
                  : null, // Disabled until complete
              style: FilledButton.styleFrom(padding: EdgeInsets.all(18.w)),
              child: Text(
                'Submit for Review',
                style: TextStyle(fontSize: 18.sp),
              ),
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
        borderRadius: BorderRadius.circular(16.r),
        side: isUploaded
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(12.w),
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
            size: 24.sp,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Text(
          isUploaded ? 'Ready for review' : 'Tap to upload',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
        ),
        trailing: isUploaded
            ? null
            : TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _uploadDoc(title);
                },
                child: Text('Upload', style: TextStyle(fontSize: 14.sp)),
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
