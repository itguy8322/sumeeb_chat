import 'package:sumeeb_chat/data/models/user/user_model.dart';

class UserState {
  final AppUser? user;
  UserState({required this.user});

  factory UserState.initial() {
    return UserState(user: null);
  }

  UserState copyWith({AppUser? user}) {
    return UserState(user: user ?? this.user);
  }
}
