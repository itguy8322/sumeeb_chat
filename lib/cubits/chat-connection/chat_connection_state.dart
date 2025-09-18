import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatConnectionState {
  final StreamChatClient? client;
  final Channel? channel;
  final String? phoneNumber;
  final bool conectingInProgress;
  final bool connectionSuccess;
  final bool connectingFailure;
  const ChatConnectionState({
    required this.client,
    required this.channel,
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
      conectingInProgress: false,
      connectionSuccess: false,
      connectingFailure: false,
    );
  }
  ChatConnectionState copyWith({
    StreamChatClient? client,
    Channel? channel,
    String? phoneNumber,
    bool? conectingInProgress,
    bool? connectionSuccess,
    bool? connectingFailure,
  }) {
    return ChatConnectionState(
      client: client ?? this.client,
      channel: channel ?? this.channel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      conectingInProgress: conectingInProgress ?? this.conectingInProgress,
      connectionSuccess: connectionSuccess ?? this.connectionSuccess,
      connectingFailure: connectingFailure ?? this.connectingFailure,
    );
  }
}
