import 'package:shared_preferences/shared_preferences.dart';

class PrefKeys {
  static String webVersion = 'web_version';
  static String localScopeId = 'local_scope_id';

  static Future<void> saveVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(webVersion, version);
  }

  static Future<String?> getVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(webVersion);
  }

  static Future<void> saveLocalScopeId(String scopeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localScopeId, scopeId);
  }

  static Future<String?> getLocalScopeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(localScopeId);
  }
}