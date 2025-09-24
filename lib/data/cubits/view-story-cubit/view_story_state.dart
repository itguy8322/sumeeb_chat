import 'package:sumeeb_chat/data/models/story-model/story_model.dart';

class ViewStoryState {
  final StoryModel? currentStory;
  final bool showViewers;
  ViewStoryState({required this.currentStory, required this.showViewers});

  factory ViewStoryState.initial() {
    return ViewStoryState(currentStory: null, showViewers: false);
  }

  ViewStoryState copyWith({StoryModel? currentStory, bool? showViewers}) {
    return ViewStoryState(
      currentStory: currentStory ?? this.currentStory,
      showViewers: showViewers ?? this.showViewers,
    );
  }
}
