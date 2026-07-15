class AppConfig {
  const AppConfig._();

  static const String defaultUserId = 'demo_user';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
