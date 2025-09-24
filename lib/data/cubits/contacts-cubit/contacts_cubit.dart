import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_state.dart';
import 'package:sumeeb_chat/data/isar-models/contacts/icontacts.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/data/repositories/firestore/firestore_repository.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final FirestoreRepository firestore;
  final Isar isar;
  ContactsCubit(this.firestore, this.isar) : super(ContactsState.initial());

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    // Very naive normalization: ensure starts with + or digits
    return digits;
  }

  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  Future<void> loadRegisteredContacts(
    List<String> phones,
    Map<String, dynamic> rawPhones,
  ) async {
    print("================FINDING CONTACTS");
    emit(
      state.copyWith(
        loadingInProgress: true,
        loadingSuccess: false,
        loadingFailure: false,
      ),
    );
    final found = await firestore.findUsersByPhones(phones, rawPhones);
    Map<String, AppUser> mappedContacts = {};
    for (AppUser user in found) {
      mappedContacts[user.id] = user;
    }
    if (found.isEmpty) {
      emit(
        state.copyWith(
          loadingInProgress: false,
          loadingSuccess: false,
          loadingFailure: true,
        ),
      );
      print("================NOR FOUND CONTACTS");
    } else {
      print("================FOUND CONTACTS");
      print(found);
      print(mappedContacts);
      emit(
        state.copyWith(
          contacts: found,
          mappedContacts: mappedContacts,
          loadingInProgress: false,
          loadingSuccess: true,
          loadingFailure: false,
        ),
      );
    }
  }

  void addContact(String name, String phone) async {
    final contact = Icontacts()
      ..name = name
      ..phone = _normalizePhone(phone);
    await isar.writeTxn(() async {
      await isar.icontacts.put(contact); // insert or update
      print("============= ADDING HISTORY =============");
    });

    fetchPhoneContacts();
    // Navigator.pop(context);
  }

  void fetchPhoneContacts() async {
    Map<String, dynamic> _phones = {};
    final phones = <String>{};
    if (Platform.isWindows) {
      final contacts = await isar.icontacts.where().findAll();

      for (final c in contacts) {
        final normalized = _normalizePhone(c.phone!);
        if (normalized.isNotEmpty) phones.add(normalized);
        _phones[normalized] = {"displayName": c.name, "name": c.name};
      }
      print("============${phones.toList()}");
      loadRegisteredContacts(phones.toList(), _phones);
    } else {
      print("============LOADINF");
      var status = await Permission.contacts.status;
      if (!status.isGranted) {
        print("============LOADINF---");
        status = await Permission.contacts.request();
      }

      if (status.isGranted) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
        );
        final phones = <String>{};
        // Contact()
        for (final c in contacts) {
          for (final p in c.phones) {
            final normalized = _normalizePhone(p.number);
            if (normalized.isNotEmpty) phones.add(normalized);
            _phones[normalized] = {
              "displayName": c.displayName,
              "name": c.name,
            };
          }
        }
        // setState(() => _phones = phones.toList());
        // Query firestore for registered users using phones
        print("============${phones.toList()}");
        loadRegisteredContacts(phones.toList(), _phones);
      }
    }

    // if (!await FlutterContacts.requestPermission()) {
    //   print("============LOADINF---");
    //   return;
    // }
  }
}
