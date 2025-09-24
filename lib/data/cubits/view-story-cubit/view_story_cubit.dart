import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/view-story-cubit/view_story_state.dart';
import 'package:sumeeb_chat/data/models/story-model/story_model.dart';

class ViewStoryCubit extends Cubit<ViewStoryState> {
  ViewStoryCubit() : super(ViewStoryState.initial());
  reset() {
    emit(ViewStoryState.initial());
  }

  onStoryChanged(StoryModel story) {
    print("================ CURRENT STORY TYPE: ${story.type}");
    emit(state.copyWith(currentStory: story));
  }

  onToggleShowViewers() {
    emit(state.copyWith(showViewers: !state.showViewers));
  }
}
