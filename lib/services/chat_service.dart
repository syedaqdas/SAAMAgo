import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/chat_message.dart';

class ChatService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<ChatModel> createOrGetChat(ChatModel chat) async {
    final docRef = _db.collection('chats').doc(chat.id);
    final doc = await docRef.get();
    
    if (doc.exists) {
      return ChatModel.fromFirestore(doc);
    }
    
    await docRef.set(chat.toFirestore());
    return chat;
  }

    Stream<List<ChatModel>> getUserChatsStream(String uid) {
    return _db.collection('chats')
        .where(Filter.or(
          Filter('borrowerId', isEqualTo: uid),
          Filter('ownerId', isEqualTo: uid),
        ))
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
          chats.sort((a, b) => (b.updatedAt ?? DateTime.now()).compareTo(a.updatedAt ?? DateTime.now()));
          return chats;
        });
  }

  Future<List<ChatModel>> getUserChats(String uid) async {
    final borrowerDocs = await _db.collection('chats').where('borrowerId', isEqualTo: uid).get();
    final ownerDocs = await _db.collection('chats').where('ownerId', isEqualTo: uid).get();
    
    final allDocs = <String, DocumentSnapshot>{};
    for (var doc in borrowerDocs.docs) {
      allDocs[doc.id] = doc;
    }
    for (var doc in ownerDocs.docs) {
      allDocs[doc.id] = doc;
    }
    
    final chats = allDocs.values.map((doc) => ChatModel.fromFirestore(doc)).toList();
    chats.sort((a, b) => (b.updatedAt ?? DateTime.now()).compareTo(a.updatedAt ?? DateTime.now()));
    return chats;
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final batch = _db.batch();
    
    final msgRef = _db.collection('chats').doc(chatId).collection('messages').doc();
    final newMsg = message.toFirestore();
    newMsg['id'] = msgRef.id;
    batch.set(msgRef, newMsg);
    
    final chatRef = _db.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
  }

  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _db.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'isRead': true,
    });
  }

  Stream<List<ChatMessage>> getMessagesStream(String chatId, String currentUid) {
    return _db.collection('chats').doc(chatId).collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc, currentUid: currentUid)).toList());
  }
}