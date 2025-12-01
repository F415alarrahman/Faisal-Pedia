import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:flutter/foundation.dart';

class ProductRepository {
  static Future<dynamic> getProduct(
    String token,
    String url,
    String idUser,
  ) async {
    FormData formData = FormData.fromMap({"token": token, "id_user": idUser});
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

  static Future<dynamic> searchProduct(
    String token,
    String url,
    String search,
  ) async {
    FormData formData = FormData.fromMap({"token": token, "search": search});
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
}
