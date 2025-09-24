import 'dart:convert';

import 'package:http/http.dart' as http;

class FileUploadRepository {
  FileUploadRepository();

  Future<String?> uploadProfilePhoto(String path) async {
    var uri = Uri.parse(
      "https://sumeebchat.pythonanywhere.com/profile-photo-upload",
    );
    var request = http.MultipartRequest('POST', uri);

    // attach file
    request.files.add(await http.MultipartFile.fromPath('file', path));

    // add other fields if needed
    // request.fields['user_id'] = "123";

    var response = await request.send();

    if (response.statusCode == 200) {
      print("✅ Upload successful");
      var responseString = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseString);
      final respPath = jsonResponse['url'];
      return respPath;
    } else {
      print("❌ Upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<String?> uploadFile(String path) async {
    var uri = Uri.parse("https://sumeebchat.pythonanywhere.com/stories-upload");
    var request = http.MultipartRequest('POST', uri);

    // attach file
    request.files.add(await http.MultipartFile.fromPath('file', path));

    // add other fields if needed
    // request.fields['user_id'] = "123";

    var response = await request.send();

    if (response.statusCode == 200) {
      print("✅ Upload successful");
      var responseString = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseString);
      final respPath = jsonResponse['url'];
      return respPath;
    } else {
      print("❌ Upload failed: ${response.statusCode}");
      return null;
    }
  }
}
