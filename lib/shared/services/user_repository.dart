import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> updateSavedPlaces(String uid, List<String> places) async {
    await _firestore.collection('users').doc(uid).update({
      'savedPlaces': places,
    });
  }

  Future<void> updatePaymentMethods(
    String uid,
    Map<String, dynamic> methods,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'paymentMethods': methods,
    });
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}

final userStreamProvider = StreamProvider.family<UserModel?, String>((
  ref,
  uid,
) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.userStream(uid);
});
