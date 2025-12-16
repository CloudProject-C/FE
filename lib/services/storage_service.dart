import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  /// FlutterSecureStorage 인스턴스 (전역적으로 한 번만 생성)
  static const _storage = FlutterSecureStorage();

  // access token 저장
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // access token 읽기
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // access token 삭제 (로그아웃 시 사용)
  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access_token');
  }

  // 모든 저장된 데이터 삭제 (정리용)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }



  // 사용자 역할 저장
  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'user_role', value: role);
  }

  // 사용자 역할 읽기
  static Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  // 사용자 역할 삭제 (로그아웃 시 사용)
  static Future<void> deleteUserRole() async {
    await _storage.delete(key: 'user_role');
  }
}


