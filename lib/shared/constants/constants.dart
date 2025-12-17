/// API 주소 등등
import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return '/api'; // Vercel rewrite
  }
  return 'http://18.209.108.20:8080'; // mobile
}
