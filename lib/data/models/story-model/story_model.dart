import 'package:sumeeb_chat/data/models/story-model/story_views_model.dart';

class StoryModel {
  final String user;
  final String storyId;
  final String type;
  final String? text;
  final String? color;
  final String? photoUrl;
  final String? videoUrl;
  final String? caption;
  final List<StoryViewsModel>? views;

  StoryModel({
    required this.user,
    required this.storyId,
    required this.type,
    this.text,
    this.color,
    this.photoUrl,
    this.videoUrl,
    this.caption,
    this.views,
  });

  factory StoryModel.fromJson(
    Map<String, dynamic> json,
    List<Map<String, dynamic>> views,
  ) {
    return StoryModel(
      user: json['userId'],
      storyId: json['storyId'],
      type: json['type'],
      text: json['text'],
      color: json['color'],
      photoUrl: json['photoUrl'],
      videoUrl: json['videoUrl'],
      caption: json['caption'],
      views: views
          .map(
            (view) => StoryViewsModel(
              storyId: view['storyId'],
              userId: view['userId'],
            ),
          )
          .toList(),
    );
  }
}
