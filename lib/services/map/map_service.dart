import 'dart:math';

import 'package:campit_frontend/services/storage_service.dart';
import 'package:campit_frontend/shared/constants/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {
  static Future<List<Map<String, dynamic>>?> fetchRestaurants(
      double lat, double lng, {String? category}) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final fetchRestaurantsUri = Uri.parse(
        "$baseUrl/v1/places/map"
            "?latitude=$lat"
            "&longitude=$lng"
            "&radius=150"
            "&sort=DISTANCE"
            "&category=$category",
      );
      final _accessToken = await StorageService.getAccessToken();
      final response = await http.get(
        fetchRestaurantsUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      print("response statusCode is: ${response.statusCode}");

      if (response.statusCode == 200) {
        final _preferenceResponse = jsonDecode(response.body);
        print('response(map): ${response.body}');

        final result = (_preferenceResponse["result"] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        return result;

      } else {
        print('서버 Error: ${response}');
        return null;
      }
    } catch (e) {
      print('클라이언트 Error: $e');
      return null;
    }
  }

  // 음식점 세부정보 요청
  static Future<String?> fetchRestaurantInfo(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return '이곳은 신선한 재료로 유명한 맛집 $id 입니다!';
  }

  // 사용자가 글 작성 가능한 위치인지 검증
  static Future<bool> canWritePost(double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 간단한 조건: 좌표가 특정 범위 내면 "대학교 근처"
    return (Random().nextBool()); // 임시: 50% 확률로 가능
  }

  static void logCurl({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    Object? body,
  }) {
    final buffer = StringBuffer();

    buffer.write("curl -X $method '${uri.toString()}'");

    headers?.forEach((key, value) {
      buffer.write(" -H '$key: $value'");
    });

    if (body != null) {
      buffer.write(" -d '${body.toString()}'");
    }

    print(buffer.toString());
  }
}
