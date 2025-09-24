import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/basic-info/basic_info_state.dart';
import 'package:sumeeb_chat/data/repositories/file_upload_repository.dart/file_upload_repository.dart';
import 'package:sumeeb_chat/data/repositories/firestore/firestore_repository.dart';

class BasicInfoCubit extends Cubit<BasicInfoState> {
  final FirestoreRepository firestore;
  final FileUploadRepository fileUpload;
  BasicInfoCubit(this.firestore, this.fileUpload)
    : super(BasicInfoState.initial());
  reset() {
    emit(BasicInfoState.initial());
  }

  onSetName(String name) {
    emit(state.copyWith(name: name));
  }

  setProfilePhotoUrl(String url) {
    emit(state.copyWith(profilePhoto: url));
  }

  setProfilePhoto(String path) async {
    emit(
      state.copyWith(
        uploadingPhotonInProgress: true,
        uploadingPhotonSuccess: false,
        uploadingPhotonFailure: false,
      ),
    );
    try {
      final url = await fileUpload.uploadProfilePhoto(path);
      if (url != null) {
        print("✅ Upload successful");
        emit(
          state.copyWith(
            profilePhoto: url,
            uploadingPhotonInProgress: false,
            uploadingPhotonSuccess: true,
            uploadingPhotonFailure: false,
          ),
        );
      } else {
        print("❌ Upload failed");
        emit(
          state.copyWith(
            uploadingPhotonInProgress: false,
            uploadingPhotonSuccess: false,
            uploadingPhotonFailure: true,
          ),
        );
      }
    } catch (e) {
      print("⚠️ Error: $e");
      emit(
        state.copyWith(
          uploadingPhotonInProgress: false,
          uploadingPhotonSuccess: false,
          uploadingPhotonFailure: true,
        ),
      );
    }
  }

  uploadBasicInfo(String id) async {
    final basicInfo = {
      "name": state.name!.trim(),
      "displayName": state.name!.trim(),
      "profilePhoto": state.profilePhoto,
    };
    emit(
      state.copyWith(
        loadingInProgress: true,
        loadingSuccess: false,
        loadingFailure: false,
      ),
    );
    try {
      await firestore.update(id, "users", basicInfo);
      emit(
        state.copyWith(
          loadingInProgress: false,
          loadingSuccess: true,
          loadingFailure: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingInProgress: false,
          loadingSuccess: false,
          loadingFailure: true,
        ),
      );
    }
  }
}
