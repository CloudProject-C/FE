/// API 주소 등등
import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return '/api'; // Vercel rewrite
  }
  return 'http://100.31.82.186:8080'; // mobile
}
