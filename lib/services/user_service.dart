import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<AppUser?> getCurrentUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return AppUser.fromMap(doc.data()!, uid);
  }

  Future<void> updateDisplayName(String newName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({
      'displayName': newName,
    });
  }

  Future<void> changePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<bool> reauthenticate(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }
}