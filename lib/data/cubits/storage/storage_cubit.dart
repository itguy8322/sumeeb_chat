// ignore_for_file: non_constant_identifier_names, unrelated_type_equality_checks, avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:sumeeb_chat/data/cubits/storage/storage_state.dart';
import 'package:sumeeb_chat/data/isar-models/app-settings/iapp_settings.dart';
import 'package:sumeeb_chat/data/isar-models/irecent-chats/irecent_chats.dart';
import 'package:sumeeb_chat/data/isar-models/viewed-story/iviewed_story.dart';

class StorageCubit extends Cubit<StorageState> {
  final Isar isar;
  StorageCubit(this.isar) : super(StorageState.initial());
  void setNumber(String phone) async {
    final appSettings = IappSettings(id: int.parse(phone))..phone = phone;
    await isar.writeTxn(() async {
      await isar.iappSettings.put(appSettings); // insert or update
      print("============= ADDING HISTORY =============");
    });
    emit(state.copyWith(appSettings: appSettings));
  }

  void setName(String id, String name) async {
    final appSettings = IappSettings(id: int.parse(id))
      ..name = name
      ..phone = state.appSettings != null ? state.appSettings!.phone : id
      ..profilePhoto = state.appSettings != null
          ? state.appSettings!.profilePhoto
          : ''
      ..darkMode = state.appSettings != null
          ? state.appSettings!.darkMode
          : true
      ..enableNotification = state.appSettings != null
          ? state.appSettings!.enableNotification
          : true;
    await isar.writeTxn(() async {
      await isar.iappSettings.put(appSettings); // insert or update
      print("============= ADDING HISTORY =============");
    });
    emit(state.copyWith(appSettings: appSettings));
  }

  void getUserData() async {
    print("LOADING USER PREFERENCE");
    try {
      final appSettings = await isar.iappSettings.where().findFirst();

      emit(state.copyWith(appSettings: appSettings));
    } catch (e) {
      emit(state.copyWith(appSettings: null));
      print("ERROR .... $e");
    }
  }

  Future<void> clearStorage() async {
    // await storage.write(key: "phoneNumber", value: "");
    await isar.writeTxn(() async {
      await isar.iappSettings.clear();
      await isar.irecentChats.clear();
      await isar.iviewedStorys.clear();
    });
  }
}
