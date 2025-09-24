import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(): super(ChatInitial());

  // Placeholder for future chat actions
}
