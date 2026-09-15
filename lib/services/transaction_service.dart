import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final String _collection = 'transactions';

  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    });
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final docRef = await _firestore.collection(_collection).add(transaction.toMap());
    final docSnapshot = await docRef.get();
    return TransactionModel.fromFirestore(docSnapshot);
  }
}
