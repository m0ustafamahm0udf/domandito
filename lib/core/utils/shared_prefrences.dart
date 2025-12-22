import 'package:flutter/cupertino.dart';
import 'package:one_context/one_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MySharedPreferences {
  static late SharedPreferences _sharedPreferences;

  static const String keyIsLoggedIn = "key_is_logIn";
  static const String keyIsEditProfile = "keyIsEditProfile";
  static const String keyIsAdmin = "keyIsAdmin";
  static const String keyPassword = "key_password";
  static const String keyId = "key_id";
  static const String keyBio = "keyBio";
  static const String keyName = "key_name";
  static const String keyUserName = "keyUserName";
  static const String keyDeviceToken = "key_device_token";
  static const String keyemail = "keyemail";
  static const String keyphone = "keyphone";
  static const String keyimage = "keyimage";
  static const String keyIsVerified = "keyIsVerified";

  static Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<void> clearProfile({required BuildContext context}) async {
    // Capture ID before clearing
    final currentUserId = userId;

    restaurantPassword = "";
    deviceToken = "";
    isLoggedIn = false;
    isEditProfile = false;
    userId = '';
    email = "";
    image = "";
    userName = "";
    phone = '';
    isVerified = false;
    userUserName = '';
    bio = '';
    await Supabase.instance.client.auth.signOut();
    if (currentUserId.isNotEmpty && currentUserId != '0') {
      try {
        await Supabase.instance.client
            .from('users')
            .update({'token': ''})
            .eq('id', currentUserId);
      } catch (e) {
        debugPrint("Error clearing token from DB: $e");
      }
    }
    OneNotification.hardReloadRoot(context);

    // Remove token from Supabase
  }

  static String get restaurantPassword =>
      _sharedPreferences.getString(keyPassword) ?? "";
  static set restaurantPassword(String value) =>
      _sharedPreferences.setString(keyPassword, value);

  static String get image => _sharedPreferences.getString(keyimage) ?? "";
  static set image(String value) =>
      _sharedPreferences.setString(keyimage, value);

  static String get bio => _sharedPreferences.getString(keyBio) ?? "";
  static set bio(String value) => _sharedPreferences.setString(keyBio, value);

  static bool get isLoggedIn =>
      _sharedPreferences.getBool(keyIsLoggedIn) ?? false;
  static set isLoggedIn(bool value) =>
      _sharedPreferences.setBool(keyIsLoggedIn, value);

  static bool get isEditProfile =>
      _sharedPreferences.getBool(keyIsEditProfile) ?? false;
  static set isEditProfile(bool value) =>
      _sharedPreferences.setBool(keyIsEditProfile, value);

  static bool get isVerified =>
      _sharedPreferences.getBool(keyIsVerified) ?? false;
  static set isVerified(bool value) =>
      _sharedPreferences.setBool(keyIsVerified, value);

  static String get userId => _sharedPreferences.getString(keyId) ?? '0';
  static set userId(String value) => _sharedPreferences.setString(keyId, value);

  static String get userName => _sharedPreferences.getString(keyName) ?? "";
  static set userName(String value) =>
      _sharedPreferences.setString(keyName, value);

  static String get userUserName =>
      _sharedPreferences.getString(keyUserName) ?? "";
  static set userUserName(String value) =>
      _sharedPreferences.setString(keyUserName, value);

  static String get deviceToken =>
      _sharedPreferences.getString(keyDeviceToken) ?? "";
  static set deviceToken(String value) =>
      _sharedPreferences.setString(keyDeviceToken, value);

  static String get email => _sharedPreferences.getString(keyemail) ?? "";
  static set email(String value) =>
      _sharedPreferences.setString(keyemail, value);

  static const String keyCanAskedAnonymously = "keyCanAskedAnonymously";

  static bool get canAskedAnonymously =>
      _sharedPreferences.getBool(keyCanAskedAnonymously) ?? true;
  static set canAskedAnonymously(bool value) =>
      _sharedPreferences.setBool(keyCanAskedAnonymously, value);

  static String get phone => _sharedPreferences.getString(keyphone) ?? "";
  static set phone(String value) =>
      _sharedPreferences.setString(keyphone, value);
}
