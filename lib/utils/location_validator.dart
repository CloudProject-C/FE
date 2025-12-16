import 'dart:math';

class LocationValidator {
  // 학교 기준 좌표
  static const double _schoolLat = 37.2479;
  static const double _schoolLng = 127.0772;

  // 허용 반경 (미터)
  static const double _allowedRadiusMeter = 300;

  /// 사용자가 글 작성 가능한 위치인지 검증
  static Future<bool> canWritePost(double lat, double lng) async {
    final distance = _calculateDistanceMeter(
      lat,
      lng,
      _schoolLat,
      _schoolLng,
    );

    return distance <= _allowedRadiusMeter;
  }

  /// 두 좌표 간 거리 계산 (Haversine 공식)
  static double _calculateDistanceMeter(
      double lat1,
      double lng1,
      double lat2,
      double lng2,
      ) {
    const double earthRadius = 6371000; // meters

    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degToRad(double deg) => deg * pi / 180;
}
