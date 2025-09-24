import 'package:flutter_bloc/flutter_bloc.dart';

class DarkModeCubit extends Cubit<bool> {
  DarkModeCubit() : super(false);

  void toggleDarkMode() async {
    // Isar isar = locator<ISarService>().instance;
    final newMode = !state;
    emit(newMode);
    // final pref = DarkModePreference(
    //     isDarkModeOn: newMode, darkModeStringId: 'DARK_MODE');
    // await isar.writeTxn(() async {
    //   await isar.darkModePreferences.put(pref);
    // });
  }

  void loadDarkModePreference() async {
    // Isar isar = await locator<ISarService>().instance;
    // DarkModePreference? prefs = await isar.darkModePreferences
    //     .where()
    //     .findFirst(); // Assuming you created a method to get the box for DarkModePreference
    // emit(prefs!.isDarkModeOn);
  }
}
