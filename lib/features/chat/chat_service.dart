import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(FirebaseFirestore.instance);
});

class ChatService {
  final FirebaseFirestore _firestore;

  ChatService(this._firestore);

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add to messages subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update last message in chat document (for sorting/preview)
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [chatId], // storing driverId as participant
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Stream messages for a specific chat
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  // Stream all active chats (for Manager)
  Stream<List<Map<String, dynamic>>> getActiveChats() {
    return _firestore
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Include the doc ID (which is the driver ID)
            return data;
          }).toList();
        });
  }
}
