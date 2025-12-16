import 'package:flutter/material.dart';
import 'map.dart'
if (dart.library.html) 'map_web.dart';

class MapPlatform extends StatelessWidget {
  final String? category;

  const MapPlatform({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return MapArea(category: category);
  }
}
