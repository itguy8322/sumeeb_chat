// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_cubit.dart';
import 'package:sumeeb_chat/data/isar-models/irecent-chats/irecent_chats.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("====== Background Push Received ======");
  // final data = message.data;
  final data = message.data;
  String title = '';
  String body = '';
  final lastMessage = data['body'];
  final userId = data['title'].toString().replaceFirst('New message from ', '');
  print("################## USER ID: $userId ##################");

  final id = "+$userId";

  body = lastMessage;

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [IrecentChatsSchema], // only this one if you just update recent chats
    directory: dir.path,
    inspector: false,
  );
  await isar.writeTxn(() async {
    final existing = await isar.irecentChats.get(int.parse(userId));
    if (existing != null) {
      print(
        "################## existing USER ID: ${existing.name} ##################",
      );
      title = "You got a message from ${existing.name ?? userId}";
      existing.lastMessage = lastMessage;
      existing.messageCount += 1;
      existing.date = DateTime.now().toString();
      existing.status = 'received';
      await isar.irecentChats.put(existing);
    } else {
      title = "You got a message from $userId";
      await isar.irecentChats.put(
        IrecentChats(id: int.parse(userId))
          ..phone = id
          ..lastMessage = lastMessage
          ..messageCount = 1
          ..date = DateTime.now().toString()
          ..status = 'received',
      );
    }
  });
  isar.close();
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecond.remainder(100000),
      channelKey: 'basic_channel',
      icon: 'resource://drawable/ic_stat_notify',
      title: title,
      body: body,
    ),
  );
  print("====== Background Push Received ======");
}

class PushNotificationService {
  static StreamSubscription<RemoteMessage>? _subscription;
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static bool _permissionsRequested = false;

  static void initialize(
    RecentChatCubit recentChatCubit,
    ContactsCubit contacts,
    ChatConnectionCubit connection,
    Isar isar,
    // UserDataCubit userDataCubit,
    // NotificationListCubit notificationCubit,
    // AppSettingsCubit appSettings,
  ) async {
    // Avoid duplicate subscriptions
    print("<========= Initializing Push Notification ===========>");

    if (!_permissionsRequested) {
      _permissionsRequested = true;
      try {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        print("Permission request failed: $e");
      }
    }
    _subscription?.cancel();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _subscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      // final data = message.data;
      // final isPushNotificationEnabled =
      //     appSettings.state.isPushNotificationsEnabled;

      print("=== Foreground Push Received ===");

      print("TOTAL RECENT CHATS: ${recentChatCubit.state.recentChats.length}");

      print("############### NOTIFICATIOM ################");
      print(message.data);
      final data = message.data;
      String title = '';
      String body = '';
      bool userState = false;
      final lastMessage = data['body'];
      final userId = data['title'].toString().replaceFirst(
        'New message from ',
        '',
      );
      print("################## USER ID: $userId ##################");
      final mappedContacts = contacts.state.mappedContacts;
      final id = "+$userId";
      print("##### MAPPED CONTACTS: $mappedContacts");
      try {
        if (mappedContacts.containsKey(id)) {
          print("User found in contacts");
          final contact = mappedContacts[id]!;
          title = "You got a message from ${contact.name}";
          body = lastMessage;
        } else {
          print("User not found in contacts, using userId as phone");
          title = "You got a message from $userId";
          body = lastMessage;
        }

        if (connection.state.otherUser != null) {
          print("########## CHECKING USER STATE IS CURRENT ##########");
          print(connection.state.otherUser!.id);
          print(userId);
          print("########## CHECKING USER STATE IS CURRENT ##########");
          userState = connection.state.otherUser!.id == id;
          print("########## NEW USER STATE: $userState");
        }

        print("########## USER STATE: $userState");
        recentChatCubit.setUnreadMessageToTrue();
        recentChatCubit.addChatToHistoryFromNotification(
          userId,
          lastMessage,
          userState,
        );
      } catch (e) {
        print("Error in processing notification: $e");
      }
      print("############### NOTIFICATIOM ################");
      if (!userState) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecond.remainder(100000),
            channelKey: 'basic_channel',
            // bigPicture: 'asset://assets/icon/icon.png',
            icon: 'resource://drawable/ic_stat_notify',
            title: title,
            body: body,
          ),
        );
      }
    });
    print("<========= Initialized Push Notification ===========>");
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
