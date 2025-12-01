import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../network/network.dart';

class AuthRepository {
  static Future<dynamic> login(
    String token,
    String url,
    String email,
    String password,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "email": email,
      "password": password,
    });
    Dio dio = Dio();
    dio.options.headers['x-username'] = xusername;
    dio.options.headers['x-password'] = xpassword;
    if (kDebugMode) {
      print("ENDPOINT URL : $url");
    }
    final response = await dio.post(url, data: formData);
    if (kDebugMode) {
      print("RESPONSE STATUS CODE : ${response.statusCode}");
    }
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("RESPONSE DATA LOGIN : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }

  static Future<dynamic> register(
    String token,
    String url,
    String namaLengkap,
    String email,
    String password,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "nama_lengkap": namaLengkap,
      "email": email,
      "password": password,
    });
    Dio dio = Dio();
    dio.options.headers['x-username'] = xusername;
    dio.options.headers['x-password'] = xpassword;
    if (kDebugMode) {
      print("ENDPOINT URL : $url");
    }
    final response = await dio.post(url, data: formData);
    if (kDebugMode) {
      print("RESPONSE STATUS CODE : ${response.statusCode}");
    }
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("RESPONSE DATA REGISTER : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }
}
