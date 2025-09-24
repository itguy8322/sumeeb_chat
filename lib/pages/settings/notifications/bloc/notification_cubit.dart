import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPreferenceCubit extends Cubit<bool> {
  NotificationsPreferenceCubit() : super(false);

  void toggleNotification(bool newMode) async {
    // Isar isar = locator<ISarService>().instance;
    emit(newMode);
    // final pref = NotificationsPreference(
    //     isNotificationOn: newMode, notificationsStringId: 'NOTIFICATION_PREF');

    // await isar.writeTxn(() async {
    //   await isar.notificationsPreferences.put(pref);
    // });
  }

  void loadNotificationPreference() async {
    // Isar isar = locator<ISarService>().instance;
    // NotificationsPreference? prefs = await isar.notificationsPreferences
    //     .where()
    //     .findFirst(); // Assuming you created a method to get the box for DarkModePreference
    // emit(prefs!.isNotificationOn);
  }
}
