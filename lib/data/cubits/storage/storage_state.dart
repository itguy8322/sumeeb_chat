import 'package:sumeeb_chat/data/isar-models/app-settings/iapp_settings.dart';

class StorageState {
  final IappSettings? appSettings;
  StorageState({required this.appSettings});
  factory StorageState.initial() {
    return StorageState(appSettings: null);
  }
  StorageState copyWith({IappSettings? appSettings}) {
    return StorageState(appSettings: appSettings ?? this.appSettings);
  }
}
