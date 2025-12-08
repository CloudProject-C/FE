import 'dart:async';

import 'package:campit_frontend/feature/map/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campit_frontend/services/map/map_service.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final Location _location = Location();
  NaverMapController? _mapController;
  LocationData? _myLocation;
  NMarker? _myDot;
  LocationData? _prevLocation;
  Timer? _lerpTimer;
  Timer? _cameraLerpTimer;
  bool _followOn = true;

  @override
  void initState() {
    super.initState();
    _initLocation();

    // 위치 변화 실시간 감지
    _location.onLocationChanged.listen((current) {
      if (!mounted) return;

      _animateMyDot(_prevLocation, current);

      if (_followOn && _mapController != null) {
        _animateCamera(_prevLocation, current);
      }

      if (!mounted) return;
      setState(() {
        _myLocation = current;
      });

      _prevLocation = current;

      // 파란 점 위치 갱신
      // if (_myDot != null &&
      //     current.latitude != null &&
      //     current.longitude != null) {
      //   _myDot!.setPosition(
      //     NLatLng(current.latitude!, current.longitude!),
      //   );
      // }

      // if (_followOn && _mapController != null) {
      //   _mapController!.updateCamera(
      //     NCameraUpdate.withParams(
      //       target: NLatLng(current.latitude!, current.longitude!),
      //     ),
      //   );
      // }
    });
  }

  @override
  void dispose() {
    // 1. 타이머 정지 (가장 중요)
    _lerpTimer?.cancel();
    _cameraLerpTimer?.cancel();

    // 2. 지도 컨트롤러 해제 (선택 사항이지만 권장)
    _mapController = null;

    super.dispose();
  }

  Future<void> _initLocation() async {
    bool enabled = await _location.serviceEnabled();
    if (!enabled) {
      enabled = await _location.requestService();
      if (!enabled) return;
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    _myLocation = await _location.getLocation();
    if (!mounted) return;
    setState(() {});
  }


  Future<void> _loadNearbyRestaurants() async {
    if (_myLocation == null) return;

    // 1. 서버에서 데이터 가져오기
    final restaurants = await MapService.fetchRestaurants(
      _myLocation!.latitude!,
      _myLocation!.longitude!,
    );

    if (restaurants == null || restaurants.isEmpty) return;

    // 2. 마커 생성 및 지도에 추가
    for (final r in restaurants) {
      // 데이터 안전하게 파싱 (String으로 올 수도 있으므로 toString 후 parse)
      final lat = double.tryParse(r['latitude'].toString()) ?? 0.0;
      final lng = double.tryParse(r['longitude'].toString()) ?? 0.0;
      final id = r['placeId'].toString();
      final name = r['placeName'] ?? '이름 없음';

      // 좌표가 0.0이면 마커 생성 스킵
      if (lat == 0.0 || lng == 0.0) continue;

      final marker = NMarker(
        id: id,
        position: NLatLng(lat, lng),
        caption: NOverlayCaption(text: name),
        size: const Size(30, 40), // 마커 크기 조절 (선택)
      );

      // 3. 마커 클릭 이벤트 (다이얼로그 표시)
      marker.setOnTapListener((overlay) async {
        // 상세 정보 가져오기 (필요하다면)
        // final info = await MapService.fetchRestaurantInfo(r['id']);

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("카테고리: ${r['categoryName'] ?? '-'}"),
                const SizedBox(height: 8),
                Text("거리: ${r['distance']}m"),
                const SizedBox(height: 8),
                // Text(info ?? '상세 정보 없음'), // 상세 정보 API가 있다면 사용
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantDetailScreen(),
                    ),
                  );
                },
                child: const Text('상세 정보'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openNaverMap(
                    _myLocation!.latitude!,
                    _myLocation!.longitude!,
                    lat, // 파싱해둔 lat 사용
                    lng, // 파싱해둔 lng 사용
                  );
                },
                child: const Text('길찾기'),
              ),
            ],
          ),
        );
      });

      // 지도에 마커 추가
      _mapController?.addOverlay(marker);
    }
  }

  Future<void> _openNaverMap(
      double startLat, double startLng, double endLat, double endLng) async {
    final url =
        'nmap://route/walk?slat=$startLat&slng=$startLng&sname=경희대학교 국제캠퍼스&dlat=$endLat&dlng=$endLng&dname=썬프란시스코마켓';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // 앱이 없으면 웹으로 연결
      final webUrl =
          'https://map.naver.com/p/directions/${startLat},${startLng},경희대학교 국제캠퍼스/${endLat},${endLng},썬프란시스코마켓';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _animateMyDot(LocationData? from, LocationData to) {
    if (_myDot == null) return;
    if (to.latitude == null || to.longitude == null) return;

    // 이전 위치가 없으면 즉시 이동
    if (from == null || from.latitude == null || from.longitude == null) {
      _myDot!.setPosition(NLatLng(to.latitude!, to.longitude!));
      return;
    }

    // 이전 타이머 있으면 중지
    _lerpTimer?.cancel();

    final startLat = from.latitude!;
    final startLng = from.longitude!;
    final endLat = to.latitude!;
    final endLng = to.longitude!;

    const duration = 700; // ms
    const fps = 60;
    final totalFrames = (fps * duration / 1000).ceil();
    int frame = 0;

    _lerpTimer = Timer.periodic(
      Duration(milliseconds: (1000 / fps).ceil()),
          (timer) {
        frame++;
        final t = frame / totalFrames; // 0.0 → 1.0

        if (t >= 1.0) {
          timer.cancel();
          _myDot!.setPosition(NLatLng(endLat, endLng));
          return;
        }

        // 선형 보간
        final curLat = startLat + (endLat - startLat) * t;
        final curLng = startLng + (endLng - startLng) * t;

        _myDot!.setPosition(NLatLng(curLat, curLng));
      },
    );
  }

  void _animateCamera(LocationData? from, LocationData to) {
    if (to.latitude == null || to.longitude == null) return;

    if (_mapController == null) return;

    // 첫 위치라면 즉시 이동
    if (from == null || from.latitude == null || from.longitude == null) {
      _mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(to.latitude!, to.longitude!),
        ),
      );
      return;
    }

    // 기존 타이머 중단
    _cameraLerpTimer?.cancel();

    final startLat = from.latitude!;
    final startLng = from.longitude!;
    final endLat = to.latitude!;
    final endLng = to.longitude!;

    const duration = 700;
    const fps = 60;
    final totalFrames = (fps * duration / 1000).ceil();
    int frame = 0;

    _cameraLerpTimer = Timer.periodic(
      Duration(milliseconds: (1000 / fps).ceil()),
          (timer) {
        frame++;
        double t = frame / totalFrames;

        // 부드러운 easeInOut 곡선 (파란 점보다 카메라에 더 적합)
        t = t * t * (3 - 2 * t);

        if (t >= 1.0) {
          timer.cancel();
          _mapController!.updateCamera(
            NCameraUpdate.withParams(
              target: NLatLng(endLat, endLng),
            ),
          );
          return;
        }

        final curLat = startLat + (endLat - startLat) * t;
        final curLng = startLng + (endLng - startLng) * t;

        _mapController!.updateCamera(
          NCameraUpdate.withParams(
            target: NLatLng(curLat, curLng),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = _myLocation?.latitude;
    final lng = _myLocation?.longitude;
    // 위치 데이터를 아직 못 가져온 경우 로딩 표시
    if (lat == null || lng == null) {
      return Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints){
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(lat, lng),
                      zoom: 15,
                    ),
                  ),
                  onMapReady: (controller) async {
                    _mapController = controller;

                    final overlayImage = await NOverlayImage.fromWidget(
                      context: context,
                      widget: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      size: const Size(18, 18),
                    );

                    _myDot = NMarker(
                      id: 'my_dot',
                      position: NLatLng(lat, lng),
                      icon: overlayImage,
                      size: const Size(18, 18),
                    );

                    _mapController?.addOverlay(_myDot!);

                    await _loadNearbyRestaurants();
                  },
                  onCameraChange: (reason, animated) {
                    if (_followOn && reason == NCameraUpdateReason.gesture) {
                      // 사용자가 카메라 움직이려고 시도함 → 바로 되돌림
                      if (_myLocation?.latitude != null && _myLocation?.longitude != null) {
                        _mapController?.updateCamera(
                          NCameraUpdate.withParams(
                            target: NLatLng(
                              _myLocation!.latitude!,
                              _myLocation!.longitude!,
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              Positioned(
                right: 16,
                bottom: 80,
                child: Column(
                  children: [
                    _zoomButton(
                      "+",
                      onTap: () {
                        _mapController?.updateCamera(
                          NCameraUpdate.zoomIn(),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _zoomButton(
                      "-",
                      onTap: () {
                        _mapController?.updateCamera(
                          NCameraUpdate.zoomOut(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 20,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _followOn = !_followOn;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Icon(
                      _followOn ? Icons.gps_fixed : Icons.gps_not_fixed,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _zoomButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
