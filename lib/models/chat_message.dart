import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    this.id = '',
    required this.text,
    required this.time,
    required this.isMine,
    this.senderId = '',
    this.senderName = '',
    this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String text;
  final String time;
  final bool isMine;
  final String senderId;
  final String senderName;
  final DateTime? createdAt;
  final bool isRead;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc, {required String currentUid}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final sId = data['senderId'] as String? ?? '';
    final created = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String? ?? '',
      time: "${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}",
      isMine: sId == currentUid,
      senderId: sId,
      senderName: data['senderName'] as String? ?? '',
      createdAt: created,
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
