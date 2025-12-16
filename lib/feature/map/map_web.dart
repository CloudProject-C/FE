import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';

class MapArea extends StatefulWidget {
  final String? category;

  const MapArea({
    super.key,
    required this.category,
  });

  @override
  State<MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<MapArea> {
  static bool _registered = false;
  final String _viewType = 'naver-map-view';

  @override
  void initState() {
    super.initState();

    if (!_registered) {
      ui.platformViewRegistry.registerViewFactory(
        _viewType,
            (int viewId) {
          final div = html.DivElement()
            ..id = 'naver-map-$viewId'
            ..style.width = '100%'
            ..style.height = '100%';
          return div;
        },
      );
      _registered = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      js_util.callMethod(
        html.window,
        'initNaverMap',
        ['naver-map-0'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300, // 테스트용, 반드시 숫자
      color: Colors.red, // 임시
      child: const HtmlElementView(
        viewType: 'naver-map-view',
      ),
    );
  }
}
