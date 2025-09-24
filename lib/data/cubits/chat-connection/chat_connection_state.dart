import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

class ChatConnectionState {
  final StreamChatClient? client;
  final Channel? channel;
  final AppUser? currentUser;
  final AppUser? otherUser;
  final StreamService? streamService;
  final String? phoneNumber;
  final bool conectingInProgress;
  final bool connectionSuccess;
  final bool connectingFailure;
  const ChatConnectionState({
    required this.client,
    required this.channel,
    required this.currentUser,
    required this.otherUser,
    required this.streamService,
    required this.phoneNumber,
    required this.conectingInProgress,
    required this.connectionSuccess,
    required this.connectingFailure,
  });
  factory ChatConnectionState.initial() {
    return ChatConnectionState(
      client: null,
      channel: null,
      phoneNumber: null,
      currentUser: null,
      otherUser: null,
      streamService: null,
      conectingInProgress: false,
      connectionSuccess: false,
      connectingFailure: false,
    );
  }
  ChatConnectionState copyWith({
    StreamChatClient? client,
    Channel? channel,
    AppUser? currentUser,
    AppUser? otherUser,
    StreamService? streamService,
    String? phoneNumber,
    bool? conectingInProgress,
    bool? connectionSuccess,
    bool? connectingFailure,
  }) {
    return ChatConnectionState(
      client: client ?? this.client,
      channel: channel ?? this.channel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentUser: currentUser ?? this.currentUser,
      otherUser: otherUser ?? this.otherUser,
      streamService: streamService ?? streamService,
      conectingInProgress: conectingInProgress ?? this.conectingInProgress,
      connectionSuccess: connectionSuccess ?? this.connectionSuccess,
      connectingFailure: connectingFailure ?? this.connectingFailure,
    );
  }
}
