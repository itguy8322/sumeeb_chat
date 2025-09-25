import 'package:sumeeb_chat/data/models/story-model/story_model.dart';

class StoryState {
  final Map<String, List<StoryModel>> stories;
  final Map<String, List<StoryModel>> viewedStories;
  List<StoryModel>? myStories;
  final List<String>? viewedStoryIds;
  final String storyId;
  final String? text;
  final String type;
  final int colorIndex;
  final String? photoUrl;
  final String? videoUrl;
  final String? caption;
  final bool showViews;
  final bool uploadingInProgress;
  final bool uploadingSuccess;
  final bool uploadingFailure;

  final bool loadingInProgress;
  final bool loadingSuccess;
  final bool loadingFailure;

  StoryState({
    required this.stories,
    required this.viewedStories,
    required this.myStories,
    required this.viewedStoryIds,
    required this.storyId,
    required this.type,
    required this.text,
    this.colorIndex = 0,
    required this.photoUrl,
    required this.videoUrl,
    required this.caption,
    required this.showViews,
    required this.uploadingInProgress,
    required this.uploadingSuccess,
    required this.uploadingFailure,
    required this.loadingInProgress,
    required this.loadingSuccess,
    required this.loadingFailure,
  });

  factory StoryState.initial() {
    return StoryState(
      stories: {},
      viewedStories: {},
      myStories: [],
      viewedStoryIds: [],
      storyId: '',
      type: '',
      text: '',
      colorIndex: 0,
      photoUrl: '',
      videoUrl: '',
      caption: '',
      showViews: false,
      uploadingInProgress: false,
      uploadingSuccess: false,
      uploadingFailure: false,
      loadingInProgress: false,
      loadingSuccess: false,
      loadingFailure: false,
    );
  }
  StoryState reset() {
    return StoryState(
      stories: stories,
      viewedStories: viewedStories,
      myStories: myStories,
      viewedStoryIds: viewedStoryIds,
      storyId: '',
      type: '',
      text: '',
      colorIndex: 0,
      photoUrl: '',
      videoUrl: '',
      caption: '',
      showViews: false,
      uploadingInProgress: false,
      uploadingSuccess: false,
      uploadingFailure: false,
      loadingInProgress: false,
      loadingSuccess: false,
      loadingFailure: false,
    );
  }

  StoryState copyWith({
    Map<String, List<StoryModel>>? stories,
    Map<String, List<StoryModel>>? viewedStories,
    List<StoryModel>? myStories,
    List<String>? viewedStoryIds,
    String? storyId,
    String? text,
    String? type,
    int? colorIndex,
    String? photoUrl,
    String? videoUrl,
    String? caption,
    bool? showViews,
    bool? uploadingInProgress,
    bool? uploadingSuccess,
    bool? uploadingFailure,
    bool? loadingInProgress,
    bool? loadingSuccess,
    bool? loadingFailure,
  }) {
    return StoryState(
      stories: stories ?? this.stories,
      viewedStories: viewedStories ?? this.viewedStories,
      myStories: myStories ?? this.myStories,
      viewedStoryIds: viewedStoryIds ?? this.viewedStoryIds,
      storyId: storyId ?? this.storyId,
      type: type ?? this.type,
      text: text ?? this.text,
      colorIndex: colorIndex ?? this.colorIndex,
      photoUrl: photoUrl ?? this.photoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      showViews: showViews ?? this.showViews,
      uploadingInProgress: uploadingInProgress ?? this.uploadingInProgress,
      uploadingSuccess: uploadingSuccess ?? this.uploadingSuccess,
      uploadingFailure: uploadingFailure ?? this.uploadingFailure,
      loadingInProgress: loadingInProgress ?? this.loadingInProgress,
      loadingSuccess: loadingSuccess ?? this.loadingSuccess,
      loadingFailure: loadingFailure ?? this.loadingFailure,
    );
  }
}
