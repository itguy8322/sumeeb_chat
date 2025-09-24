// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:isar/isar.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_cubit.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
  Isar isar,
) async {
  print("====== Background Push Received ======");
  // final data = message.data;
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecond.remainder(100000),
      channelKey: 'basic_channel',
      icon: 'resource://drawable/ic_stat_notify',
      title: message.notification?.title ?? "New message",
      body: message.notification?.body ?? "You got a message",
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
    FirebaseMessaging.onBackgroundMessage((message) {
      return firebaseMessagingBackgroundHandler(message, isar);
    });
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
      final lastMessage = data['body'];
      final userId = data['title'].toString().replaceFirst(
        'New message from ',
        '',
      );
      print("################## USER ID: $userId ##################");
      final mappedContacts = contacts.state.mappedContacts;
      print("##### MAPPED CONTACTS: $mappedContacts");
      if (mappedContacts.containsKey(userId)) {
        print("User found in contacts");
        final contact = mappedContacts[userId]!;
        title = "You got a message from ${contact.name}";
        body = lastMessage;
      } else {
        print("User not found in contacts, using userId as phone");
        title = "You got a message from $userId";
        body = lastMessage;
      }
      recentChatCubit.addChatToHistoryFromNotification(userId, lastMessage);

      print("############### NOTIFICATIOM ################");

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
    });
    print("<========= Initialized Push Notification ===========>");
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
