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

  @override
  void initState() {
    super.initState();
    _initLocation();
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
    setState(() {});
  }

  Future<void> _loadNearbyRestaurants() async {
    if (_myLocation == null) return;

    final restaurants = await MapService.fetchRestaurants(
      _myLocation!.latitude!,
      _myLocation!.longitude!,
    );

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
                    _openNaverMap(
                      _myLocation!.latitude!,
                      _myLocation!.longitude!,
                      r['lat'],
                      r['lng'],
                    );
                  },
                  child: const Text('길찾기'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
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
                    await _loadNearbyRestaurants();
                  },
                ),
              ),
              Positioned(
                right: 16,
                bottom: 100,
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

              // Positioned(
              //   right: 16,
              //   bottom: 16,
              //   child: FloatingActionButton(
              //     onPressed: () async {
              //       final canWrite = await MapService.canWritePost(lat, lng);
              //       showDialog(
              //         context: context,
              //         builder: (_) => AlertDialog(
              //           title: const Text('글 작성 가능 여부'),
              //           content: Text(canWrite
              //               ? '500m 내 대학교 근처입니다. 글 작성 가능 ✅'
              //               : '대학교 근처가 아닙니다 ❌'),
              //         ),
              //       );
              //     },
              //     child: const Icon(Icons.edit),
              //   ),
              // ),
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
