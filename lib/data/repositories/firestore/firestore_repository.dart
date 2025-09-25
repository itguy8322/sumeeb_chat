// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sumeeb_chat/data/models/story-model/story_model.dart';
import '../../models/user/user_model.dart';

class FirestoreRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _users = 'users';

  FirestoreRepository();

  Future<AppUser?> findUserByPhone(String phone) async {
    final q = await db
        .collection(_users)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final d = q.docs.first.data();
    print(d);
    return AppUser.fromMap(d);
  }

  Future<void> createUser(AppUser user) async {
    print("============= CREATE NEW USER: ${user.id}");
    final docRef = db.collection(_users).doc(user.id);
    await docRef.set(user.toMap(), SetOptions(merge: true));
  }

  Future<List<AppUser>> findUsersByPhones(
    List<String> phones,
    Map<String, dynamic> rawPhones,
  ) async {
    if (phones.isEmpty) return [];
    final batches = <List<String>>[];
    for (var i = 0; i < phones.length; i += 10) {
      batches.add(
        phones.sublist(i, i + 10 > phones.length ? phones.length : i + 10),
      );
    }

    final results = <AppUser>[];
    for (final batch in batches) {
      final q = await db
          .collection(_users)
          .where('phone', whereIn: batch)
          .get();
      for (final doc in q.docs) {
        final displayName = rawPhones[doc.id]['displayName'];
        results.add(
          AppUser.fromMap({
            ...doc.data(),
            'id': doc.id,
            "disPlayName": displayName,
          }),
        );
      }
    }
    return results;
  }

  Future<void> update(
    String id,
    String collection,
    Map<String, dynamic> data,
  ) async {
    await db.collection(collection).doc(id).update(data);
  }

  Future<void> uploadStory(String collection, Map<String, dynamic> data) async {
    await db.collection(collection).doc(data['storyId']).set(data);
  }

  Future<bool> addViewToStory(String storyId, AppUser user) async {
    print("ADDD VIEWS ======================");
    print(storyId);
    final query = await db
        .collection("stories")
        .doc(storyId)
        .collection("views")
        .where("userId", isEqualTo: user.id)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return false;
    }
    await db.collection("stories").doc(storyId).collection("views").doc().set({
      "storyId": storyId,
      "userId": user.id,
      "name": user.name,
      "viewAt": FieldValue.serverTimestamp(),
    });
    return true;
  }

  Future<List<StoryModel>> loadStory(String userId) async {
    print("########## THIS USER ################3");
    print(userId);
    print("########## THIS USER ################3");

    final snapshot = await db
        .collection('stories')
        .where("userId", isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    // Map all docs directly into StoryModel list
    List<StoryModel> stories = [];
    for (var doc in snapshot.docs) {
      final viewsSnapshots = await doc.reference.collection('views').get();
      final views = viewsSnapshots.docs.map((view) => view.data()).toList();
      print("#############@@@@@@@@@@@@@@##### $views");
      print(doc.data()['color']);
      stories.add(StoryModel.fromJson(doc.data(), views));
    }

    return stories;
  }

  Future<List<AppUser>> getAll() async {
    final snapshot = await db.collection('users').get();
    final users = snapshot.docs.map((doc) {
      return AppUser.fromMap(doc.data());
    }).toList();
    return users;
  }

  Future<AppUser?> getData(String id) async {
    final doc = await db.collection('users').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }
}
