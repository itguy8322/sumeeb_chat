import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _users = 'users';

  FirestoreRepository();

  Future<AppUser?> findUserByPhone(String phone) async {
    final q = await _db
        .collection(_users)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final d = q.docs.first.data();
    return AppUser.fromMap({...d, 'id': q.docs.first.id});
  }

  Future<void> createUser(AppUser user) async {
    print("============= CREATE NEW USER: ${user.id}");
    final docRef = _db.collection(_users).doc(user.id);
    await docRef.set(user.toMap(), SetOptions(merge: true));
  }

  Future<List<AppUser>> findUsersByPhones(List<String> phones) async {
    if (phones.isEmpty) return [];
    final batches = <List<String>>[];
    for (var i = 0; i < phones.length; i += 10) {
      batches.add(
        phones.sublist(i, i + 10 > phones.length ? phones.length : i + 10),
      );
    }

    final results = <AppUser>[];
    for (final batch in batches) {
      final q = await _db
          .collection(_users)
          .where('phone', whereIn: batch)
          .get();
      for (final doc in q.docs) {
        results.add(AppUser.fromMap({...doc.data(), 'id': doc.id}));
      }
    }
    return results;
  }
}
