import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rental_request.dart';

class BorrowRequestService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<RentalRequest> createRequest(RentalRequest request) async {
    final docRef = request.id.endsWith('-') || request.id.isEmpty
        ? _db.collection('borrow_requests').doc()
        : _db.collection('borrow_requests').doc(request.id);
    
    final finalRequest = request.id != docRef.id ? request.copyWith(id: docRef.id) : request;
    await docRef.set(finalRequest.toFirestore());
    return finalRequest;
  }

    Stream<List<RentalRequest>> getRequestsForUserStream(String uid) {
    return _db.collection('borrow_requests')
        .where(Filter.or(
          Filter('borrowerId', isEqualTo: uid),
          Filter('ownerId', isEqualTo: uid),
        ))
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => RentalRequest.fromFirestore(doc))
              .toList();
          requests.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
          return requests;
        });
  }

  Future<List<RentalRequest>> getRequestsForUser(String uid) async {
    // Queries can only contain one equality on different fields OR we do two separate queries and combine them.
    // Firestore allows 'in' but for a single field. Here we need borrowerId == uid OR ownerId == uid.
    // So we fetch both and merge them, removing duplicates if any.
    final borrowerDocs = await _db
        .collection('borrow_requests')
        .where('borrowerId', isEqualTo: uid)
        .get();

    final ownerDocs = await _db
        .collection('borrow_requests')
        .where('ownerId', isEqualTo: uid)
        .get();

    final allDocs = <String, DocumentSnapshot>{};
    for (var doc in borrowerDocs.docs) {
      allDocs[doc.id] = doc;
    }
    for (var doc in ownerDocs.docs) {
      allDocs[doc.id] = doc;
    }

    final requests = allDocs.values
        .map((doc) => RentalRequest.fromFirestore(doc))
        .toList();
        
    requests.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    return requests;
  }

  Future<RentalRequest?> getRequest(String id) async {
    final doc = await _db.collection('borrow_requests').doc(id).get();
    if (doc.exists) {
      return RentalRequest.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateRequestStatus(String id, RequestStatus status) async {
    await _db.collection('borrow_requests').doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelRequest(String id) async {
    await updateRequestStatus(id, RequestStatus.cancelled);
  }
}
