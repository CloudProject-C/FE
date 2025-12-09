import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campit_frontend/shared/constants/constants.dart';
import 'package:campit_frontend/services/storage_service.dart';

class ProfileService {
  static String? _normalizeAccessToken(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;

    final dotCount = '.'.allMatches(t).length;

    if (dotCount >= 2 && !t.startsWith('{')) {
      return t;
    }

    if (t.startsWith('{')) {
      try {
        final m = jsonDecode(t);
        if (m is Map<String, dynamic>) {
          final r = m['result'];
          if (r is String && r.trim().isNotEmpty) {
            return r.trim();
          }
        }
      } catch (_) {
      }
    }
    return t;
  }

  static Future<String?> _getAccessTokenSafe() async {
    final raw = await StorageService.getAccessToken();
    return _normalizeAccessToken(raw);
  }

  static Map<String, String> _buildHeaders(String? token) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> getMyEmailFromToken() async {
    final token = await _getAccessTokenSafe();
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);

      if (map is Map<String, dynamic>) {
        final sub = map['sub'];
        if (sub is String && sub.trim().isNotEmpty) {
          return sub.trim();
        }
      }
    } catch (_) {
    }
    return null;
  }

  /// ===============================
  /// 1) 마이 페이지 조회
  /// GET /v1/users/me
  /// ===============================
  static Future<Map<String, dynamic>?> fetchMyPage() async {
    final uri = Uri.parse('$baseUrl/v1/users/me');
    final token = await _getAccessTokenSafe();
    final headers = _buildHeaders(token);

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// ===============================
  /// 2) 내가 작성한 리뷰 목록
  /// GET /v1/users/me/reviews
  /// ===============================
  static Future<Map<String, dynamic>?> fetchMyReviews({
    String sort = 'LATEST',
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/v1/users/me/reviews').replace(
      queryParameters: {
        'sort': sort,
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final token = await _getAccessTokenSafe();
    final headers = _buildHeaders(token);

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// ===============================
  /// 3) 내가 좋아요한 음식점 목록
  /// GET /v1/users/me/likes
  /// ===============================
  static Future<Map<String, dynamic>?> fetchMyLikes({
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/v1/users/me/likes').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final token = await _getAccessTokenSafe();
    final headers = _buildHeaders(token);

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
