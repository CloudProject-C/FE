

import 'package:campit_frontend/services/storage_service.dart';
import 'package:campit_frontend/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeService{
  static Future<Map<String, dynamic>?> fetch_onboarding_preference() async {
    final _preferenceUri = Uri.parse('$baseUrl/v1/preference/onboarding').toString();

    final response = await http.post(
      Uri.parse(_preferenceUri),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final _preferenceResponse = jsonDecode(response.body);
      return _preferenceResponse;
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetch_login_preference() async {
    final _preferenceUri = Uri.parse('$baseUrl/v1/preference/recommend').toString();

    final response = await http.post(
      Uri.parse(_preferenceUri),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final _preferenceResponse = jsonDecode(response.body);
      return _preferenceResponse;
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetch_home_data() async {
    final _homeUri = Uri.parse('$baseUrl/v1/main').toString();
    final _accessToken = await StorageService.getAccessToken();
    final response = await http.get(
      Uri.parse(_homeUri),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if(response.statusCode == 200){
      final _homeResponse = jsonDecode(response.body);
      return _homeResponse;
    } else {
      debugPrint('=====statusCode is ${response.statusCode}=====');
      return null;
    }
  }
}