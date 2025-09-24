import 'package:isar/isar.dart';

part 'iviewed_story.g.dart';

@collection
class IviewedStory {
  Id id = Isar.autoIncrement;
  String storyId; // a
  IviewedStory({required this.storyId});
}
