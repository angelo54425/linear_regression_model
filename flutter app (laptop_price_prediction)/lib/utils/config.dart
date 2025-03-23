class AppConfig {
  // Use environment variables or secure storage in a real app
  static const String apiBaseUrl = "http://192.168.1.72:8000"; // Replace in production
  static const String apiEndpoint = "/predict";
  static const int apiTimeout = 10;
}