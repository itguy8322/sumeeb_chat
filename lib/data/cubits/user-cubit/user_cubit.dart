import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/data/repositories/file_upload_repository.dart/file_upload_repository.dart';
import 'package:sumeeb_chat/data/repositories/firestore/firestore_repository.dart';

class UserCubit extends Cubit<UserState> {
  final FirestoreRepository firestore;
  final FileUploadRepository fileUpload;
  UserCubit(this.firestore, this.fileUpload) : super(UserState.initial());

  reset() {
    emit(UserState.initial());
  }

  loadUser(String id) async {
    final user = await firestore.getData(id);
    setUuser(user!);
  }

  setUuser(AppUser user) {
    emit(state.copyWith(user: user));
  }

  setProfilePhotoUrl(String url) {
    emit(
      state.copyWith(
        newProfilePhotoUrl: url,
        uploadingInProgress: false,
        uploadingSuccess: false,
        uploadingFailure: false,
      ),
    );
  }

  uploadProfilePhoto() async {
    emit(
      state.copyWith(
        uploadingInProgress: true,
        uploadingSuccess: false,
        uploadingFailure: false,
      ),
    );
    try {
      final url = await fileUpload.uploadProfilePhoto(state.newProfilePhotoUrl);
      if (url != null) {
        print("✅ Upload successful");
        await firestore.update(state.user!.id, "users", {"profilePhoto": url});
        final updatedUser = AppUser(
          id: state.user!.id,
          name: state.user!.name,
          disPlayName: state.user!.disPlayName,
          profilePhoto: url,
          phone: state.user!.phone,
        );
        emit(
          state.copyWith(
            user: updatedUser,
            newProfilePhotoUrl: "",
            uploadingInProgress: false,
            uploadingSuccess: true,
            uploadingFailure: false,
          ),
        );
      } else {
        print("❌ Upload failed");
        emit(
          state.copyWith(
            uploadingInProgress: false,
            uploadingSuccess: false,
            uploadingFailure: true,
          ),
        );
      }
    } catch (e) {
      print("⚠️ Error: $e");
      emit(
        state.copyWith(
          uploadingInProgress: false,
          uploadingSuccess: false,
          uploadingFailure: true,
        ),
      );
    }
  }

  // savePhotoAndName();
  uploadBasicInfo(String id, String name) async {
    emit(
      state.copyWith(
        uploadingInProgress: true,
        uploadingSuccess: false,
        uploadingFailure: false,
      ),
    );
    try {
      if (state.newProfilePhotoUrl.isEmpty) {
        final basicInfo = {
          "name": name.trim(),
          "displayName": name.trim(),
          "profilePhoto": state.user!.profilePhoto,
        };
        await firestore.update(id, "users", basicInfo);
        final updatedUser = AppUser(
          id: state.user!.id,
          name: name.trim(),
          disPlayName: name.trim(),
          profilePhoto: state.user!.profilePhoto,
          phone: state.user!.phone,
        );
        emit(
          state.copyWith(
            user: updatedUser,
            uploadingInProgress: false,
            uploadingSuccess: true,
            uploadingFailure: false,
          ),
        );
        return;
      }
      final url = await fileUpload.uploadProfilePhoto(state.newProfilePhotoUrl);
      if (url != null) {
        final basicInfo = {
          "name": name.trim(),
          "displayName": name.trim(),
          "profilePhoto": url,
        };
        await firestore.update(id, "users", basicInfo);
        final updatedUser = AppUser(
          id: state.user!.id,
          name: name.trim(),
          disPlayName: name.trim(),
          profilePhoto: url,
          phone: state.user!.phone,
        );
        emit(
          state.copyWith(
            user: updatedUser,
            uploadingInProgress: false,
            uploadingSuccess: true,
            uploadingFailure: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          uploadingInProgress: false,
          uploadingSuccess: false,
          uploadingFailure: true,
        ),
      );
    }
  }

  removeProfilePhoto(String id) async {
    emit(
      state.copyWith(
        uploadingInProgress: true,
        uploadingSuccess: false,
        uploadingFailure: false,
      ),
    );
    try {
      await firestore.update(id, "users", {"profilePhoto": ""});
      final updatedUser = AppUser(
        id: state.user!.id,
        name: state.user!.name,
        disPlayName: state.user!.disPlayName,
        profilePhoto: "",
        phone: state.user!.phone,
      );
      emit(
        state.copyWith(
          user: updatedUser,
          newProfilePhotoUrl: "",
          uploadingInProgress: false,
          uploadingSuccess: true,
          uploadingFailure: false,
        ),
      );
    } catch (e) {
      print("################ Error: $e ################");
      emit(
        state.copyWith(
          uploadingInProgress: false,
          uploadingSuccess: false,
          uploadingFailure: true,
        ),
      );
    }
  }
}
