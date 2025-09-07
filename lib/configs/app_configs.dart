class AppConfigs {
  static bool isDemo = false;
  static String domainUrl = 'https://daily.pls.edu.vn';
  static String databaseId = isDemo ? 'develop' : '(default)';
  static String apiTranslate = '127.0.0.1:8000';
}