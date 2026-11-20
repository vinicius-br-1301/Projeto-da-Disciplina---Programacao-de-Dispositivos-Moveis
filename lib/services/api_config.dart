class ApiConfig {
  // escolher a URL conforme onde estiver testando
  // - Chrome (Web):        'http://localhost:8080'
  // - Emulador Android:    'http://10.0.2.2:8080'
  // - Celular físico WiFi: 'http://SEU_IP_LOCAL:8080' (descobrir com ip config no termnial)
  static const String baseUrl = 'http://localhost:8080';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
}
