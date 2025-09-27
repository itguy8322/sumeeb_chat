import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/data/repositories/firestore/firestore_repository.dart';

class UserCubit extends Cubit<UserState> {
  final FirestoreRepository firestore;
  UserCubit(this.firestore) : super(UserState.initial());

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

  removeProfilePhoto() {}
}
