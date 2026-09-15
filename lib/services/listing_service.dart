import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rental_item.dart';

class ListingService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<RentalItem> createListing(RentalItem item) async {
    final docRef = item.id.endsWith('-') || item.id.isEmpty 
        ? _db.collection('listings').doc() 
        : _db.collection('listings').doc(item.id);
    
    final finalItem = item.id != docRef.id ? item.copyWith(id: docRef.id) : item;
    await docRef.set(finalItem.toFirestore());
    return finalItem;
  }

    Stream<List<RentalItem>> getListingsStream() {
    return _db.collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RentalItem.fromFirestore(doc)).toList());
  }

  Future<List<RentalItem>> getListings() async {
    final snapshot = await _db.collection('listings')
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => RentalItem.fromFirestore(doc)).toList();
  }

  Future<RentalItem?> getListing(String id) async {
    final doc = await _db.collection('listings').doc(id).get();
    if (doc.exists) {
      return RentalItem.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('listings').doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _db.collection('listings').doc(id).delete();
  }
}
