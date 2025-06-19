class ApiConfig {
  static const bool isProd = false;

  static String get baseUrl {
    return isProd
        ? 'https://fitness-api.onrender.com'
        : 'http://10.0.2.2:3000';
  }
}
