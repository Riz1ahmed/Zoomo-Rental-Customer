import 'package:shared_preferences/shared_preferences.dart';

/// Holds the logged-in client's doc id and persists it locally across app
/// restarts so the user stays signed in on this device.
class Session {
  Session._();
  static final Session instance = Session._();

  static const _clientIdKey = 'session_client_id';

  String? clientId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    clientId = prefs.getString(_clientIdKey);
  }

  Future<void> login(String id) async {
    clientId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientIdKey, id);
  }

  Future<void> logout() async {
    clientId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientIdKey);
  }

  bool get isLoggedIn => clientId != null;
}
