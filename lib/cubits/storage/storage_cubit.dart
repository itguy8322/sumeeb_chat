// ignore_for_file: non_constant_identifier_names, unrelated_type_equality_checks, avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageCubit extends Cubit<Map<String, dynamic>> {
  final storage = FlutterSecureStorage();
  StorageCubit() : super({"remember_me": false});
  void setUserData(String name, String phoneNumber) async {
    //print(!state["remember_me"]);
    print("SETTING USER PREFERENCE");
    await storage.write(key: "name", value: name);
    await storage.write(key: "phoneNumber", value: phoneNumber);
    emit({"phoneNumber": phoneNumber});
  }

  void getUserData() async {
    print("LOADING USER PREFERENCE");
    Map<String, dynamic> newData = Map<String, dynamic>.from(state);
    try {
      String? name = await storage.read(key: "name");
      String? phoneNumber = await storage.read(key: "phoneNumber");
      newData["name"] = name;
      newData["phoneNumber"] = phoneNumber;

      emit(newData);
    } catch (e) {
      print("ERROR ....");
      emit({"name": null, "phoneNumber": null});
    }
  }

  clearStorage() async {
    await storage.write(key: "phoneNumber", value: "");
  }
}
