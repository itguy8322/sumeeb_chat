import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/cubits/chat-connection/chat_connection_state.dart';
import 'package:sumeeb_chat/models/user_model.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

class ChatConnectionCubit extends Cubit<ChatConnectionState> {
  ChatConnectionCubit() : super(ChatConnectionState.initial());
  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  makeConnection(
    AppUser currentUser,
    AppUser otherUser,
    StreamService streamService,
  ) async {
    emit(
      state.copyWith(
        conectingInProgress: true,
        connectionSuccess: false,
        connectingFailure: false,
      ),
    );

    try {
      print("=============== CONNECTING OTHER USER: ${otherUser.id}");
      try {
        await streamService.connectUser(
          formatUserId(otherUser.id),
          otherUser.name,
        );
      } catch (e) {
        // handle
        print('Stream connect error: $e');
      }
      final channel = await streamService.createOrGetDirectChannel(
        formatUserId(currentUser.id),
        formatUserId(otherUser.id),
      );
      emit(
        state.copyWith(
          // client: client,
          channel: channel,
          conectingInProgress: false,
          connectionSuccess: true,
          connectingFailure: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          conectingInProgress: false,
          connectionSuccess: false,
          connectingFailure: true,
        ),
      );
    }
  }
}
