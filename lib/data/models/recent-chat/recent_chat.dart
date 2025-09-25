import 'package:sumeeb_chat/data/models/user/user_model.dart';

class RecentChatModel {
  final AppUser user;
  final String message;
  final String messageCount;
  final String date;
  final String status;
  RecentChatModel({
    required this.user,
    required this.message,
    required this.messageCount,
    required this.date,
    required this.status,
  });
}
