import 'package:sumeeb_chat/data/models/story-model/story_model.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

enum PageType {
  defaultPage,
  chatroom,
  status,
  contacts,
  textStory,
  mediaStory,
  viewProfilePhoto,
}

class SidebarManagerState {
  final PageType page;
  final AppUser? user;
  final AppUser? other;
  final String userId;
  final bool isMe;
  final StreamService? streamService;
  final List<StoryModel>? stories;
  SidebarManagerState({
    required this.page,
    required this.user,
    required this.other,
    required this.userId,
    required this.isMe,
    required this.streamService,
    required this.stories,
  });

  factory SidebarManagerState.initial() {
    return SidebarManagerState(
      page: PageType.defaultPage,
      user: null,
      other: null,
      userId: '',
      isMe: true,
      streamService: null,
      stories: null,
    );
  }

  SidebarManagerState copWith({
    PageType? page,
    AppUser? user,
    AppUser? other,
    bool? isMe,
    StreamService? streamService,
    String? userId,

    List<StoryModel>? stories,
  }) {
    return SidebarManagerState(
      page: page ?? this.page,
      user: user ?? this.user,
      other: other ?? this.other,
      streamService: streamService ?? this.streamService,
      userId: userId ?? this.userId,
      isMe: isMe ?? this.isMe,
      stories: stories ?? this.stories,
    );
  }
}
