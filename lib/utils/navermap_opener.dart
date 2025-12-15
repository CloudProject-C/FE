import 'package:url_launcher/url_launcher.dart';

class NaverMapOpener {
  Future<void> openNaverMap({
    double? startLat,
    double? startLng,
    String? startName = "내 위치",
    required double endLat,
    required double endLng,
    required String endName,
  }) async {
    final String sEndLat = endLat.toStringAsFixed(7);
    final String sEndLng = endLng.toStringAsFixed(7);
    final encodedEndName = Uri.encodeComponent(endName);

    // 1. 앱 실행 시도 (nmap 스키마 - 가이드 준수)
    // 앱 스키마는 dlat, dlng, slat, slng를 사용합니다.
    String url = 'nmap://route/walk?dlat=$sEndLat&dlng=$sEndLng&dname=$encodedEndName&appname=com.example.campit_frontend';

    if (startLat != null && startLng != null) {
      final String sStartLat = startLat.toStringAsFixed(7);
      final String sStartLng = startLng.toStringAsFixed(7);
      final encodedStartName = Uri.encodeComponent(startName ?? "내 위치");
      url += "&slat=$sStartLat&slng=$sStartLng&sname=$encodedStartName";
    }

    final Uri uri = Uri.parse(url);

    bool appLaunched = false;
    try {
      if (await canLaunchUrl(uri)) {
        appLaunched = await launchUrl(uri);
      }
    } catch (e) {
      // 무시하고 웹으로 진행
    }

    // 2. 앱 실행 실패 시 웹으로 이동
    if (!appLaunched) {
      String webUrl;

      if (startLat != null && startLng != null) {
        final String sStartLat = startLat.toStringAsFixed(7);
        final String sStartLng = startLng.toStringAsFixed(7);
        final encodedStartName = Uri.encodeComponent(startName ?? "내 위치");

        // [수정 완료] 모바일 웹 전용 파라미터 적용
        // sx: 출발 경도, sy: 출발 위도
        // ex: 도착 경도, ey: 도착 위도
        webUrl = 'https://m.map.naver.com/route.naver?menu=route&pubTransType=WALK'
            '&sx=$sStartLng&sy=$sStartLat&sname=$encodedStartName'
            '&ex=$sEndLng&ey=$sEndLat&ename=$encodedEndName'; // dname이 아니라 ename일 수 있음 (웹 기준)

      } else {
        // 출발지 없을 때 (도착지 검색)
        webUrl = 'https://m.map.naver.com/search2/search.naver?query=$encodedEndName&sm=hty&style=v5';
      }

      print("Generated Web URL: $webUrl");
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
}