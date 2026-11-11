import 'package:dio/dio.dart';

class AniListClient {
  AniListClient(this._dio);

  final Dio _dio;
  static const String _endpoint = 'https://graphql.anilist.co';

  Future<Map<String, dynamic>> query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _endpoint,
      data: <String, dynamic>{
        'query': query,
        'variables': ?variables,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        headers: const <String, String>{'Accept': 'application/json'},
      ),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid AniList response');
    }
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: _endpoint),
        error: errors.first,
        type: DioExceptionType.badResponse,
      );
    }
    final result = data['data'];
    if (result is! Map<String, dynamic>) {
      throw const FormatException('Missing AniList data');
    }
    return result;
  }
}
