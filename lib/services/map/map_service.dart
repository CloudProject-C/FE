import 'dart:math';

class MapService {
  // 가짜 음식점 데이터 (예시)
  static Future<List<Map<String, dynamic>>> fetchRestaurants(
      double lat, double lng) async {
    await Future.delayed(const Duration(seconds: 1));

    return List.generate(3, (i) {
      final offset = 0.002 * (i + 1);
      return {
        'id': i + 1,
        'name': '맛집 ${i + 1}',
        'lat': lat + offset,
        'lng': lng + offset,
      };
    });
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
}
