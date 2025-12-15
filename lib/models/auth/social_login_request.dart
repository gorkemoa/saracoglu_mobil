class SocialLoginRequest {
  final String platform; // "google" or "apple"
  final String deviceID;
  final String devicePlatform; // "ios" or "android"
  final String version;
  final String accessToken;
  final String? fcmToken;
  final String? idToken; // For Apple Sign In

  SocialLoginRequest({
    required this.platform,
    required this.deviceID,
    required this.devicePlatform,
    required this.version,
    required this.accessToken,
    this.fcmToken,
    this.idToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'platform': platform,
      'deviceID': deviceID,
      'devicePlatform': devicePlatform,
      'version': version,
      'accessToken': accessToken,
    };

    if (fcmToken != null) {
      data['fcmToken'] = fcmToken;
    }

    if (idToken != null) {
      data['idToken'] = idToken;
    }

    return data;
  }
}
