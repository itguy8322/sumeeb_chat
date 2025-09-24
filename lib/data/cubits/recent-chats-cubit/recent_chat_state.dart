import 'package:sumeeb_chat/data/models/recent-chat/recent_chat.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';

class RecentChatState {
  final List<RecentChatModel> recentChats;
  RecentChatState({required this.recentChats});

  factory RecentChatState.initial() {
    return RecentChatState(recentChats: []);
  }
  RecentChatState copyWith({List<RecentChatModel>? recentChats}) {
    return RecentChatState(recentChats: recentChats ?? this.recentChats);
  }
}
