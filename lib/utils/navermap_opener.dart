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

    // 1. 앱 실행 시도 (nmap 스키마)
    // route/walk : 도보 경로 (이미 적용됨)
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

        // [수정] 도보 경로 파라미터 확실하게 적용
        // pathType=1 (도보) 추가 (0: 추천, 1: 도보 등 상황에 따라 다를 수 있으나 pubTransType=WALK가 핵심)
        webUrl = 'https://m.map.naver.com/route.naver?menu=route&pubTransType=WALK&pathType=3'
            '&sx=$sStartLng&sy=$sStartLat&sname=$encodedStartName'
            '&ex=$sEndLng&ey=$sEndLat&ename=$encodedEndName';

      } else {
        // 출발지 없을 때
        webUrl = 'https://m.map.naver.com/search2/search.naver?query=$encodedEndName&sm=hty&style=v5';
      }

      print("Generated Web URL: $webUrl");
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
}