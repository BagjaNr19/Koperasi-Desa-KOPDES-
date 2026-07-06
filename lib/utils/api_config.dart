import 'dart:io' show Platform;

class ApiConfig {
  // Gunakan 10.0.2.2 untuk Android Emulator, dan 127.0.0.1 untuk Windows/Desktop
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://127.0.0.1:3000/api';
  }
}
