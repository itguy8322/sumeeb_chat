import 'package:sumeeb_chat/data/models/user/user_model.dart';

class UserState {
  final AppUser? user;
  final String newProfilePhotoUrl;
  final bool uploadingInProgress;
  final bool uploadingSuccess;
  final bool uploadingFailure;
  UserState({
    required this.user,
    required this.newProfilePhotoUrl,
    required this.uploadingInProgress,
    required this.uploadingSuccess,
    required this.uploadingFailure,
  });

  factory UserState.initial() {
    return UserState(
      user: null,
      newProfilePhotoUrl: "",
      uploadingInProgress: false,
      uploadingSuccess: false,
      uploadingFailure: false,
    );
  }

  UserState copyWith({
    AppUser? user,
    String? newProfilePhotoUrl,
    bool? uploadingInProgress,
    bool? uploadingSuccess,
    bool? uploadingFailure,
  }) {
    return UserState(
      user: user ?? this.user,
      newProfilePhotoUrl: newProfilePhotoUrl ?? this.newProfilePhotoUrl,
      uploadingInProgress: uploadingInProgress ?? this.uploadingInProgress,
      uploadingSuccess: uploadingSuccess ?? this.uploadingSuccess,
      uploadingFailure: uploadingFailure ?? this.uploadingFailure,
    );
  }
}
