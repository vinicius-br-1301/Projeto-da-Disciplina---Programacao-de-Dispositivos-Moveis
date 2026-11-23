class ApiConfig {
  // - Chrome (Web):        'http://localhost:8080'
  // - Emulador Android:    'http://10.0.2.2:8080'
  // - Celular físico WiFi: 'http://MEU_IP_LOCAL:8080'
  static const String baseUrl = 'http://localhost:8080';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
}
