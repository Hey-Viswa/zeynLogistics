import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  StorageService();

  Future<String?> uploadProfileImage(String uid, XFile imageFile) async {
    try {
      // Fallback for users without Storage: Convert to Base64
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;

      /* 
      // Original Cloud Storage Code (Disabled)
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL();
      */
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  Future<String?> uploadDriverDocument(
    String uid,
    String docType,
    XFile imageFile,
  ) async {
    try {
      // Fallback for users without Storage: Convert to Base64
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      print('Error converting driver document: $e');
      return null;
    }
  }
}
