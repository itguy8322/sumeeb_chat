import 'package:isar/isar.dart';

part 'irecent_chats.g.dart';

@collection
class IrecentChats {
  Id id; // auto increment ID
  String? name;
  String? phone;
  String? profilePhoto;
  String? lastMessage;
  String? date;
  String? status;
  int messageCount = 0;
  IrecentChats({required this.id});
}
