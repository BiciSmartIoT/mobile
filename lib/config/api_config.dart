class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://back-end-production-7214.up.railway.app',
  );

  static Uri uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse(baseUrl);
    final query = queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return base.replace(
      path: normalizedPath,
      queryParameters: query?.isEmpty ?? true ? null : query,
    );
  }
}
