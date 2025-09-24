import 'package:isar/isar.dart';

part 'iapp_settings.g.dart';

@collection
class IappSettings {
  Id id; // auto increment ID
  String? name;
  String? phone;
  String? profilePhoto;
  bool? darkMode;
  bool? enableNotification;
  IappSettings({required this.id});
}
