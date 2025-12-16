import 'dart:ui_web' as ui;
import 'dart:html';
import 'package:flutter/material.dart';

class MapArea extends StatelessWidget {
  final String? category;

  MapArea({
    super.key,
    required this.category,
  }) {
    ui.platformViewRegistry.registerViewFactory(
      'naver-map',
          (int viewId) {
        final div = DivElement()
          ..id = 'naver-map-div'
          ..style.width = '100%'
          ..style.height = '100%';
        return div;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'naver-map');
  }
}
