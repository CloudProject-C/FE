import 'package:location/location.dart';

class CurrentPositionGetter {
  //현재 위치를 불러오는 함수
  static Future<LocationData?> getCurrentPosition() async {
    print('=== getCurrentPosition START ===');

    final Location location = Location();

    try {
      // 1️⃣ 위치 서비스 확인
      print('[1] Checking location service...');
      bool enabled = await location.serviceEnabled();
      print('[1-1] serviceEnabled = $enabled');

      if (!enabled) {
        print('[1-2] Requesting location service...');
        enabled = await location.requestService();
        print('[1-3] requestService result = $enabled');

        if (!enabled) {
          print('[STOP] Location service disabled');
          return null;
        }
      }

      // 2️⃣ 권한 확인
      print('[2] Checking permission...');
      PermissionStatus permission = await location.hasPermission();
      print('[2-1] hasPermission = $permission');

      if (permission == PermissionStatus.denied) {
        print('[2-2] Requesting permission...');
        permission = await location.requestPermission();
        print('[2-3] requestPermission result = $permission');

        if (permission != PermissionStatus.granted) {
          print('[STOP] Permission not granted');
          return null;
        }
      }

      if (permission == PermissionStatus.deniedForever) {
        print('[STOP] Permission deniedForever');
        return null;
      }

      // 3️⃣ 위치 요청
      print('[3] Calling getLocation()...');
      final locationData = await location
          .getLocation()
          .timeout(const Duration(seconds: 1), onTimeout: () {
        print('[TIMEOUT] getLocation timeout');
        return LocationData.fromMap({});
      });

      // 4️⃣ 결과 검증
      if (locationData.latitude == null || locationData.longitude == null) {
        print('[FAIL] LocationData is invalid');
        return null;
      }

      print('[SUCCESS] Location acquired');
      print('  latitude  = ${locationData.latitude}');
      print('  longitude = ${locationData.longitude}');
      print('  accuracy  = ${locationData.accuracy}');
      print('  time      = ${locationData.time}');

      return locationData;
    } catch (e, stack) {
      print('[ERROR] getCurrentPosition exception');
      print(e);
      print(stack);
      return null;
    } finally {
      print('=== getCurrentPosition END ===');
    }
  }
}