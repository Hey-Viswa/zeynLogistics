import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

class StorageService {
  final FirebaseStorage _storage;

  StorageService(this._storage);

  Future<String?> uploadProfileImage(String uid, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL();
    } catch (e) {
      // Handle errors appropriately (log them, rethrow, etc.)
      return null;
    }
  }

  Future<String?> uploadDriverDocument(
    String uid,
    String docType,
    XFile imageFile,
  ) async {
    try {
      final ref = _storage
          .ref()
          .child('driver_documents')
          .child(uid)
          .child('$docType.jpg');
      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
