import 'package:isar/isar.dart';

part 'icontacts.g.dart';

@collection
class Icontacts {
  Id id = Isar.autoIncrement;
  String? name;
  String? phone;
}
