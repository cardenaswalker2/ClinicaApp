import 'dart:convert';
import 'dart:io';

class AppConfig {
  static const String baseUrl = "https://clinicaapp-fh9j.onrender.com/api";
  static String get webBaseUrl => baseUrl.replaceAll('/api', '');

  static String? userEmail;
  static String? userName;
  static String? userId;
  static String? userRole;

  static File get _sessionFile =>
      File('${Directory.systemTemp.path}/clinicaapp_session.json');

  static Future<void> saveSession() async {
    try {
      await _sessionFile.writeAsString(json.encode({
        'userEmail': userEmail,
        'userName': userName,
        'userId': userId,
        'userRole': userRole,
      }));
    } catch (_) {}
  }

  static Future<void> loadSession() async {
    try {
      if (await _sessionFile.exists()) {
        final data = json.decode(await _sessionFile.readAsString());
        userEmail = data['userEmail'];
        userName = data['userName'];
        userId = data['userId'];
        userRole = data['userRole'];
      }
    } catch (_) {}
  }

  static Future<void> clearSession() async {
    userEmail = null;
    userName = null;
    userId = null;
    userRole = null;
    try {
      if (await _sessionFile.exists()) {
        await _sessionFile.delete();
      }
    } catch (_) {}
  }
}
