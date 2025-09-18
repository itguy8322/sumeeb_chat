import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';
import '../repositories/firestore_repository.dart';

abstract class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<AppUser> contacts;
  ContactsLoaded(this.contacts);
}

class ContactsEmpty extends ContactsState {}

class ContactsCubit extends Cubit<ContactsState> {
  final FirestoreRepository firestore;
  ContactsCubit(this.firestore) : super(ContactsInitial());

  Future<void> loadRegisteredContacts(List<String> phones) async {
    print("================FINDING CONTACTS");
    emit(ContactsLoading());
    final found = await firestore.findUsersByPhones(phones);
    if (found.isEmpty) {
      emit(ContactsEmpty());
      print("================NOR FOUND CONTACTS");
    } else {
      print("================FOUND CONTACTS");
      emit(ContactsLoaded(found));
    }
  }
}
