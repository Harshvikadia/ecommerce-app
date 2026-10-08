import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  static const _userKey = 'username';
  static const _imageKey = 'user_image';

  final SharedPreferences _prefs;
  String? _username;
  String? _image;

  ProfileProvider(this._prefs)
      : _username = _prefs.getString(_userKey),
        _image = _prefs.getString(_imageKey);

  String? get username => _username;
  String? get image => _image;
  bool get isLoggedIn => _username != null && _username!.isNotEmpty;

  // Login screen se call hoga: profile.login('emilys', image: 'https://...')
  Future<void> login(String username, {String? image}) async {
    _username = username;
    _image = image;
    notifyListeners();
    await _prefs.setString(_userKey, username);
    if (image != null) {
      await _prefs.setString(_imageKey, image);
    } else {
      await _prefs.remove(_imageKey);
    }
  }

  Future<void> logout() async {
    _username = null;
    _image = null;
    notifyListeners();
    await _prefs.remove(_userKey);
    await _prefs.remove(_imageKey);
  }
}