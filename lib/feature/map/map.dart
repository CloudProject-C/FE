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

    final restaurants = await MapService.fetchRestaurants(
      _myLocation!.latitude!,
      _myLocation!.longitude!,
    );

    if(restaurants == null) return;

    for (final r in restaurants) {
      final marker = NMarker(
        id: r['id'].toString(),
        position: NLatLng(r['lat'], r['lng']),
        caption: NOverlayCaption(text: r['name']),
      );

      marker.setOnTapListener((overlay) async {
        final info = await MapService.fetchRestaurantInfo(r['id']);
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(r['name']),
              content: Text(info ?? '정보를 불러오지 못했습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RestaurantDetailScreen(),
                      ),
                    );
                  },
                  child: const Text('정보 보기'),
                ),
                TextButton(
                  onPressed: () {
                    _openNaverMap(
                      _myLocation!.latitude!,
                      _myLocation!.longitude!,
                      r['lat'],
                      r['lng'],
                    );
                  },
                  child: const Text('길찾기'),
                ),
              ],
            ),
          );
        }
      });

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
