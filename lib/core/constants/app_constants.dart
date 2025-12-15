import 'dart:io';

/// Uygulama sabitleri
/// Versiyon, platform ve diğer uygulama bilgileri
class AppConstants {
  AppConstants._();

  /// Uygulama versiyonu

  /// Platform bilgisi (dinamik)
  static String get platform {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    }
    return 'unknown';
  }

  /// Paket adı
}
