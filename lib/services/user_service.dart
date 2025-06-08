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

  Future<List<AppUser>> searchUsersByEmail(String emailQuery) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final query = await _db
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: emailQuery)
        .where('email', isLessThanOrEqualTo: emailQuery + '\uf8ff')
        .get();

    return query.docs
        .where((doc) => doc.id != currentUser.uid) // exclude self
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addFriend(String friendUid) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userRef = _db.collection('users').doc(uid);
    await userRef.update({
      'friends': FieldValue.arrayUnion([friendUid]),
    });
  }

  Future<List<AppUser>> getFriendsOfCurrentUser() async {
    final user = await getCurrentUserData();
    if (user == null || user.friends.isEmpty) return [];

    final snapshots = await _db
        .collection('users')
        .where(FieldPath.documentId, whereIn: user.friends)
        .get();

    return snapshots.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();
  }

}