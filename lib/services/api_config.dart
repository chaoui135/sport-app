import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const bool isProd = false;

  static String get baseUrl {
    return isProd
        ? dotenv.env['API_URL_PROD'] ?? ''
        : dotenv.env['API_URL_DEV'] ?? '';
  }
}
