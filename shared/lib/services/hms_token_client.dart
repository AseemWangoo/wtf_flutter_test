import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/rtc_config.dart';

class HmsTokenClient {
  HmsTokenClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> fetchToken({
    required String userId,
    required String role,
    required String roomId,
  }) async {
    final uri = Uri.parse('${RtcConfig.tokenServerUrl}/token').replace(
      queryParameters: {
        'userId': userId,
        'role': role,
        'roomId': roomId,
      },
    );
    debugPrint('[RTC] fetch token user=$userId role=$role room=$roomId');
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw HmsTokenException(
        'Token server ${response.statusCode}: ${response.body}',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final token = json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw HmsTokenException('Token missing in response');
    }
    return token;
  }
}

class HmsTokenException implements Exception {
  HmsTokenException(this.message);
  final String message;

  @override
  String toString() => message;
}
