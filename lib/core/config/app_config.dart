class AppConfig {
  static const String quranAuthToken = String.fromEnvironment('QURAN_AUTH_TOKEN', defaultValue: '');
  static const String quranClientId = String.fromEnvironment('QURAN_CLIENT_ID', defaultValue: '');

  static Map<String, String> get apiHeaders {
    final headers = <String, String>{
      'User-Agent': 'TajweedQuranApp/1.0',
      'Accept': 'application/json',
    };
    if (quranAuthToken.isNotEmpty) {
      headers['x-auth-token'] = quranAuthToken;
    }
    if (quranClientId.isNotEmpty) {
      headers['x-client-id'] = quranClientId;
    }
    return headers;
  }
}
