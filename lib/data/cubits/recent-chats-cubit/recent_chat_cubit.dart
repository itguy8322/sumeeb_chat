// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_state.dart';
import 'package:sumeeb_chat/data/isar-models/irecent-chats/irecent_chats.dart';
import 'package:sumeeb_chat/data/models/recent-chat/recent_chat.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/data/repositories/firestore/firestore_repository.dart';

class RecentChatCubit extends Cubit<RecentChatState> {
  final Isar isar;
  final FirestoreRepository firestore;
  RecentChatCubit(this.isar, this.firestore) : super(RecentChatState.initial());
  //   Future<void> addUser() async {

  // }
  setUnreadMessageToTrue() {
    emit(state.copyWith(hasUnreadMessages: true));
  }

  setUnreadMessageToFalse() async {
    bool? hasUnread = false;
    final users = await isar.irecentChats.where().findAll();
    for (IrecentChats user in users) {
      if (user.messageCount > 0) {
        hasUnread = true;
        break;
      }
    }
    emit(state.copyWith(hasUnreadMessages: hasUnread));
  }

  addChatToHistory(AppUser user, String message) async {
    print("============= ADDING HISTORY =============");
    final recentChatUser = await isar.irecentChats.get(int.parse(user.id));
    if (recentChatUser != null) {
      print("User exists, updating message count");
      recentChatUser.messageCount += 1;
      recentChatUser.lastMessage = message;
      recentChatUser.date = DateTime.now().toString();
      recentChatUser.status = 'sent';
      await isar.writeTxn(() async {
        await isar.irecentChats.put(recentChatUser); // insert or update
        print("============= UPDATING HISTORY =============");
      });
      getRecentChats();
      return;
    }
    final recentUser = IrecentChats(id: int.parse(user.id))
      ..name = user.name
      ..phone = user.phone
      ..lastMessage = message
      ..profilePhoto = user.profilePhoto
      ..date = DateTime.now().toString()
      ..status = 'sent';
    // final newRecentChats = List<RecentChatModel>.from(state.recentChats);
    await isar.writeTxn(() async {
      await isar.irecentChats.put(recentUser); // insert or update
      print("============= ADDING HISTORY =============");
    });
    getRecentChats();
  }

  updateChatToHistory(AppUser user, String message, String date) async {
    print("============= ADDING HISTORY =============");
    final recentUser = await isar.irecentChats.get(int.parse(user.id));
    if (recentUser != null) {
      recentUser.name = user.name;
      recentUser.phone = user.phone;
      recentUser.lastMessage = message;
      recentUser.profilePhoto = user.profilePhoto;
      recentUser.date = date;
      // final newRecentChats = List<RecentChatModel>.from(state.recentChats);
      await isar.writeTxn(() async {
        await isar.irecentChats.put(recentUser); // insert or update
        print("============= UPDATING HISTORY =============");
      });
    }
    // getRecentChats();
  }

  addChatToHistoryFromNotification(
    String phone,
    String message,
    bool isCurrent,
  ) async {
    print("============= ADDING HISTORY FROM NOTIFICATION =============");
    final recentChatUser = await isar.irecentChats.get(int.parse(phone));
    if (recentChatUser != null) {
      print("User exists, updating message count");
      if (!isCurrent) {
        recentChatUser.messageCount += 1;
      }
      recentChatUser.lastMessage = message;
      recentChatUser.date = DateTime.now().toString();
      recentChatUser.status = 'received';
      await isar.writeTxn(() async {
        await isar.irecentChats.put(recentChatUser); // insert or update
        print("============= UPDATING HISTORY =============");
      });
      getRecentChats();
      return;
    }
    final _user = await firestore.getData("+$phone");
    String name = phone;
    String profilePhoto = '';
    if (_user != null) {
      name = _user.name.isNotEmpty ? _user.name : phone;
      profilePhoto = _user.profilePhoto ?? '';
    }
    final recentUser = IrecentChats(id: int.parse(phone))
      ..name = name
      ..phone = phone
      ..lastMessage = message
      ..profilePhoto = profilePhoto
      ..messageCount += 1
      ..date = DateTime.now().toString()
      ..status = 'received';
    // final newRecentChats = List<RecentChatModel>.from(state.recentChats);
    await isar.writeTxn(() async {
      await isar.irecentChats.put(recentUser); // insert or update
      print("============= ADDING HISTORY =============");
    });
    getRecentChats();
  }

  getRecentChats() async {
    final users = await isar.irecentChats.where().findAll();
    List<RecentChatModel> recentChats = [];
    bool hasUnread = false;
    // final updatedProfiles = {for (var b in _users) b.id: b.profilePhoto};
    for (IrecentChats user in users) {
      print(">>>>>>>>>>>> UPDATED DPS: ${user.id}");
      try {
        if (user.messageCount > 0) {
          hasUnread = true;
        }

        final _user = await firestore.getData("+${user.id}");
        if (_user != null) {
          final appUser = AppUser(
            id: _user.phone!,
            name: _user.name,
            phone: _user.phone,
            disPlayName: _user.name,
            profilePhoto: _user.profilePhoto,
          );
          final recentChat = RecentChatModel(
            user: appUser,
            message: user.lastMessage!,
            messageCount: "${user.messageCount}",
            date: user.date ?? '',
            status: user.status ?? 'received',
          );
          recentChats.add(recentChat);
          updateChatToHistory(appUser, user.lastMessage!, user.date ?? '');
        }
      } catch (e) {
        print(
          "<<<<<<<<<>>>>>>>>>>> ERROR could not update REcent CHat for this user ${user.id}",
        );
        final recentChat = RecentChatModel(
          user: AppUser(
            id: user.phone!,
            name: user.name!,
            phone: user.phone,
            disPlayName: user.name!,
            profilePhoto: user.profilePhoto,
          ),
          message: user.lastMessage!,
          messageCount: user.messageCount.toString(),
          date: user.date!,
          status: user.status!,
        );
        recentChats.add(recentChat);
      }
    }

    emit(
      state.copyWith(recentChats: recentChats, hasUnreadMessages: hasUnread),
    );
    print("---=====================${state.recentChats}");
  }

  Future<void> resetMessageCount(String id) async {
    final recentChatUser = await isar.irecentChats.get(int.parse(id));
    if (recentChatUser != null) {
      print("============= RESETTING MESSAGE COUNT =============");
      recentChatUser.messageCount = 0;
      await isar.writeTxn(() async {
        await isar.irecentChats.put(recentChatUser); // insert or update
        print("============= RESETTING MESSAGE COUNT =============");
      });
      getRecentChats();
    }
  }

  Future<void> deleteUser(int id) async {
    await isar.writeTxn(() async {
      await isar.irecentChats.delete(id);
    });
  }
}
