import 'package:sumeeb_chat/data/models/recent-chat/recent_chat.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';

class RecentChatState {
  final List<RecentChatModel> recentChats;
  final bool hasUnreadMessages;
  RecentChatState({required this.recentChats, required this.hasUnreadMessages});

  factory RecentChatState.initial() {
    return RecentChatState(recentChats: [], hasUnreadMessages: false);
  }
  RecentChatState copyWith({
    List<RecentChatModel>? recentChats,
    bool? hasUnreadMessages,
  }) {
    return RecentChatState(
      recentChats: recentChats ?? this.recentChats,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }
}
