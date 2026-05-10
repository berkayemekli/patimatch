enum AppEnv { staging, prod }

class AppEnvConfig {
  static const String _envValue =
      String.fromEnvironment('APP_ENV', defaultValue: 'prod');

  static AppEnv get current =>
      _envValue.toLowerCase() == 'staging' ? AppEnv.staging : AppEnv.prod;

  static bool get isStaging => current == AppEnv.staging;
  static String get name => isStaging ? 'staging' : 'prod';
}

