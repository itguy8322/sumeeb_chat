import 'package:isar/isar.dart';

part 'iuser.g.dart'; // generated file

@collection
class Iuser {
  Id id = Isar.autoIncrement; // auto increment ID
  late String name;
  String? phone;
  String? profilePhoto;
}
