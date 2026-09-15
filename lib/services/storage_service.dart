import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<String?> uploadListingImage(String localPath) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null; // Developer login, or unauthenticated

    final file = File(localPath);
    if (!await file.exists()) return null;
    
    final length = await file.length();
    if (length > 10 * 1024 * 1024) { // 10MB limit
      throw Exception('Image size exceeds 10MB limit.');
    }

    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'listing_images/$uid/$uniqueId.jpg';
    
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String?> uploadProfileImage(String localPath) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final file = File(localPath);
    if (!await file.exists()) return null;
    
    final length = await file.length();
    if (length > 10 * 1024 * 1024) { // 10MB limit
      throw Exception('Image size exceeds 10MB limit.');
    }

    final path = 'profile_images/$uid/profile.jpg';
    
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    
    return await uploadTask.ref.getDownloadURL();
  }
}
