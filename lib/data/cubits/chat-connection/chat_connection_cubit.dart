import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

class ChatConnectionCubit extends Cubit<ChatConnectionState> {
  ChatConnectionCubit() : super(ChatConnectionState.initial());
  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  resetConnection() {
    emit(ChatConnectionState.initial());
  }

  setStreamService(StreamService streamService) {
    print("<<<<<<<<<<<<<<<<<<<<<<SETTING STREAM SERVICE>>>>>>>>>>>>>>>>>>>>>>");
    print(streamService);
    print("<<<<<<<<<<<<<<<<<<<<<<SETTING STREAM SERVICE>>>>>>>>>>>>>>>>>>>>>>");
    emit(state.copyWith(streamService: streamService));
    print(state.streamService);
    print("<<<<<<<<<<<<<<<<<<<<<<SETTING STREAM SERVICE>>>>>>>>>>>>>>>>>>>>>>");
  }

  makeConnection(
    AppUser currentUser,
    AppUser otherUser,
    StreamService streamService,
  ) async {
    emit(
      state.copyWith(
        currentUser: currentUser,
        otherUser: otherUser,
        conectingInProgress: true,
        connectionSuccess: false,
        connectingFailure: false,
      ),
    );

    try {
      print("=============== CONNECTING OTHER USER: ${otherUser.id}");
      try {
        // await streamService.connectUser(
        //   formatUserId(otherUser.id),
        //   otherUser.name,
        // );
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
