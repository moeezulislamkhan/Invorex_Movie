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

  /// Get detailed information about a specific video including playback URL
  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    if (!AppConfig.isMuxConfigured) {
      throw MuxVideoApiException(
        'MUX video API is not configured. Add your environment key in lib/config/app_config.dart.',
      );
    }

    final uri = Uri.parse('${AppConfig.muxBaseUrl}${AppConfig.muxVideoApiPath}/videos/$videoId');

    try {
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw MuxVideoApiException(
          'Failed to fetch video details. Status: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['data'] ?? data;
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

  /// Get the playback URL for a video
  /// Returns the master.m3u8 URL for HLS streaming
  Future<String?> getPlaybackUrl(String videoId) async {
    try {
      final details = await getVideoDetails(videoId);
      
      // MUX provides playback_ids for accessing videos
      final playbackIds = details['playback_ids'] as List?;
      if (playbackIds == null || playbackIds.isEmpty) {
        throw MuxVideoApiException('No playback IDs found for video: $videoId');
      }

      // Get the first playback ID (usually policy type 'public')
      final playbackId = playbackIds.first['id'] as String?;
      if (playbackId == null) {
        throw MuxVideoApiException('Could not extract playback ID');
      }

      // Construct the HLS stream URL
      // Format: https://stream.mux.com/{playback_id}.m3u8
      final playbackUrl = 'https://stream.mux.com/$playbackId.m3u8';
      return playbackUrl;
    } catch (e) {
      throw MuxVideoApiException('Failed to get playback URL: $e');
    }
  }
}
