import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';
import '../repositories/firestore_repository.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}

class AuthCubit extends Cubit<AuthState> {
  final FirestoreRepository firestore;
  AuthCubit(this.firestore) : super(AuthInitial());

  Future<void> login({required String name, required String phone}) async {
    emit(AuthLoading());
    final normalizedPhone = _normalizePhone(phone);
    final existing = await firestore.findUserByPhone(normalizedPhone);
    if (existing != null) {
      print("==========ALREADY AUTH");
      emit(AuthAuthenticated(existing));
      return;
    }

    final user = AppUser(
      id: normalizedPhone,
      name: name,
      phone: normalizedPhone,
    );
    await firestore.createUser(user);
    emit(AuthAuthenticated(user));
  }

  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return digits;
  }

  void logout() => emit(AuthUnauthenticated());
}
