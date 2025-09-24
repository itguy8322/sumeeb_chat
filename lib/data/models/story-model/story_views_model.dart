class StoryViewsModel {
  String storyId;
  String userId;
  StoryViewsModel({required this.storyId, required this.userId});

  StoryViewsModel fromJson(Map<String, dynamic> json) {
    return StoryViewsModel(storyId: json['storyId'], userId: json['userId']);
  }
}
