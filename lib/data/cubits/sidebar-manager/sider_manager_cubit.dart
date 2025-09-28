import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sidebar_manager_state.dart';
import 'package:sumeeb_chat/data/models/story-model/story_model.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

class SiderManagerCubit extends Cubit<SidebarManagerState> {
  SiderManagerCubit() : super(SidebarManagerState.initial());
  resetToDefaultPage() {
    emit(state.copWith(page: PageType.defaultPage));
  }

  onViewProfilePhotoPage(AppUser user, bool isMe) {
    emit(
      state.copWith(page: PageType.viewProfilePhoto, user: user, isMe: isMe),
    );
  }

  onViewStatusPage(AppUser user, String userId, List<StoryModel> stories) {
    print("CHANGINF ==================");
    emit(
      state.copWith(
        page: PageType.status,
        user: user,
        userId: userId,
        stories: stories,
      ),
    );
  }

  onViewChatroomPage() {
    print("CHANGINF ==================");
    emit(state.copWith(page: PageType.chatroom));
  }

  onViewContactsPage(AppUser user, StreamService streamService) {
    print("CHANGINF ==================");
    emit(
      state.copWith(
        page: PageType.contacts,
        user: user,
        streamService: streamService,
      ),
    );
  }

  onViewTextStoryPage(AppUser user) {
    print("CHANGINF ==================");
    emit(state.copWith(page: PageType.textStory, user: user));
  }

  onViewMediaStoryPage(AppUser user) {
    print("CHANGINF ==================");
    emit(state.copWith(page: PageType.mediaStory, user: user));
  }
}
