import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class MuxVideoApiException implements Exception {
  MuxVideoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MuxVideoApiService {
  MuxVideoApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => {
        'Authorization': 'Basic ${base64Encode(utf8.encode(':${AppConfig.muxEnvironmentKey}'))}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> getVideos({int? limit}) async {
    if (!AppConfig.isMuxConfigured) {
      throw MuxVideoApiException(
        'MUX video API is not configured. Add your environment key in lib/config/app_config.dart.',
      );
    }

    final uri = Uri.parse('${AppConfig.muxBaseUrl}${AppConfig.muxVideoApiPath}/videos')
        .replace(queryParameters: {
          if (limit != null) 'limit': limit.toString(),
        });

    try {
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw MuxVideoApiException(
          'The MUX video service returned ${response.statusCode}.',
        );
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw MuxVideoApiException(
        'The request took too long. Please check your network and try again.',
      );
    } on FormatException {
      throw MuxVideoApiException('The server returned invalid data.');
    } on http.ClientException {
      throw MuxVideoApiException(
        'Could not connect to the MUX video service. Please try again.',
      );
    }
  }
}
