import 'package:sumeeb_chat/data/models/user/user_model.dart';

class ContactsState {
  final List<AppUser> contacts;
  final Map<String, AppUser> mappedContacts;
  final bool loadingInProgress;
  final bool loadingSuccess;
  final bool loadingFailure;
  ContactsState({
    required this.contacts,
    required this.mappedContacts,
    required this.loadingInProgress,
    required this.loadingSuccess,
    required this.loadingFailure,
  });

  factory ContactsState.initial() {
    return ContactsState(
      contacts: [],
      mappedContacts: {},
      loadingInProgress: false,
      loadingSuccess: false,
      loadingFailure: false,
    );
  }

  ContactsState copyWith({
    List<AppUser>? contacts,
    Map<String, AppUser>? mappedContacts,
    bool? loadingInProgress,
    bool? loadingSuccess,
    bool? loadingFailure,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      mappedContacts: mappedContacts ?? this.mappedContacts,
      loadingInProgress: loadingInProgress ?? this.loadingInProgress,
      loadingSuccess: loadingSuccess ?? this.loadingSuccess,
      loadingFailure: loadingFailure ?? this.loadingFailure,
    );
  }
}
