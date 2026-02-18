import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {

  static late SharedPreferences sharedPreferences;

  static Future init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static void clear() {
    sharedPreferences.clear();
  }

  static AndroidOptions getAndroidOptions() => const AndroidOptions(encryptedSharedPreferences: true);
  static IOSOptions getIOSOptions() => const IOSOptions();

  static final FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: getAndroidOptions(),
    iOptions: getIOSOptions()
  );

  static String? getUserId() {
    String? auth = sharedPreferences.getString("auth");

    if(auth != null) {
      Map<String, dynamic> data = json.decode(sharedPreferences.getString("auth")!);
      return data["id"];
    }
    
    return "-";
  }

  static Future<void> saveToken({required String token}) async {
    await storage.write(
      key: "token", 
      value: token
    );
  }

  static Future<String> getToken() async {
    String? token = await storage.read(key: 'token');

    return token ?? "-";
  } 

  static void removeToken() async {
    await storage.delete(key: 'token');
  }

  static Future<bool?> isLoggedIn() async {
    var token = await storage.read(key: 'token');

    return token != null 
    ? true 
    : false;
  }
  
}