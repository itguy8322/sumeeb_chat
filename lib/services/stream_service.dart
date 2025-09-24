import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/services/push_notification_service.dart';

class StreamService {
  // Replace with your Stream API key (from dashboard)
  final String apiKey = '7abupczs27ee';
  // If you set your Stream app to Development in dashboard, set useDevToken = true
  final bool useDevToken = true;

  // Token endpoint on your backend that creates user tokens securely with Stream API secret.
  // For Android emulator, use http://10.0.2.2:3000/token?user_id=...

  late final StreamChatClient client;

  StreamService() {
    client = StreamChatClient(apiKey, logLevel: Level.OFF);
  }
  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  Future<void> connectUser(String userId, String userName) async {
    // final token = await _fetchToken(userId);
    final currentUserId = formatUserId(userId);
    print("============ CUREENT User :$currentUserId");
    final user = User(
      id: currentUserId,
      extraData: {'name': userId, 'phone': currentUserId},
    );

    if (useDevToken) {
      await client.connectUser(user, client.devToken(currentUserId).rawValue);
    } else {
      await client.connectUser(user, client.devToken(user.id).rawValue);
    }
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print("################### FCM TOKEN ###################");
      print(fcmToken);
      print("################### FCM TOKEN ###################");
      await client.addDevice(
        fcmToken,
        PushProvider.firebase,
        pushProviderName: "Sumeeb-Chat",
      );
      print("📲 Registered FCM token with Stream: $fcmToken");
      print("################### FCM TOKEN ###################");
    }
  }

  Future<Channel> createOrGetDirectChannel(
    String currentUserId,
    String otherUserId,
  ) async {
    print("< =======================  CURRENT USER: $currentUserId");
    print("< =======================  OTHER USER: $otherUserId");
    final channel = client.channel(
      'messaging',
      extraData: {
        'members': [otherUserId, currentUserId],
      },
    );
    await channel.watch();
    return channel;
  }

  Future<void> sendMessage(Channel channel, String text) async {
    await channel.sendMessage(Message(text: text));
  }
}
