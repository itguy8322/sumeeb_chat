// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("====== Foreground Push Received ======");
  final data = message.data;
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecond.remainder(100000),
      channelKey: 'basic_channel',
      bigPicture: 'asset://assets/icon/icon.png',
      title: message.notification?.title ?? "New message",
      body: message.notification?.body ?? data['text'] ?? "You got a message",
      payload: {
        "channel_id": data['channel_id'] ?? '',
        "message_id": data['message_id'] ?? '',
        "sender": data['sender'] ?? '',
      },
    ),
  );
  print("====== Foreground Push Received ======");
}

class PushNotificationService {
  static StreamSubscription<RemoteMessage>? _subscription;
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static bool _permissionsRequested = false;

  static void initialize(
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
    _subscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      // final isPushNotificationEnabled =
      //     appSettings.state.isPushNotificationsEnabled;

      print("=== Foreground Push Received ===");
      print("Data: $data");
      print("Notification: ${message.notification}");

      // if (!isPushNotificationEnabled) return;

      // Always try to get title/body either from notification payload or data
      // final title = message.notification?.title ?? data['title'] ?? 'No title';
      // final body = message.notification?.body ?? data['content'] ?? 'No body';

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecond.remainder(100000),
          channelKey: 'basic_channel',
          bigPicture: 'asset://assets/icon/icon.png',
          title: message.notification?.title ?? "New message",
          body:
              message.notification?.body ?? data['text'] ?? "You got a message",
          payload: {
            "channel_id": data['channel_id'] ?? '',
            "message_id": data['message_id'] ?? '',
            "sender": data['sender'] ?? '',
          },
        ),
      );

      // Handle extra data
      // if (data.isNotEmpty && data["userId"] != null) {
      //   print("================ DATA ================");
      //   print(data);
      //   print("================ DATA ================");
      //   userDataCubit.load_user_data(data["userId"]);
      //   notificationCubit.setUnreadNotifications(true);
      // }
    });
    print("<========= Initialized Push Notification ===========>");
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
