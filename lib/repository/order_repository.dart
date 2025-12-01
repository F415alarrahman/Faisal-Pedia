import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:flutter/foundation.dart';

class OrderRepository {
  static Future<dynamic> createOrder(
    String token,
    String url,
    String idUser,
    String buyerName,
    String buyerPhone,
    String buyerAddress,
    List<Map<String, dynamic>> items,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "id_user": idUser,
      "buyer_name": buyerName,
      "buyer_phone": buyerPhone,
      "buyer_address": buyerAddress,
      "items_json": jsonEncode(items),
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

  static Future<dynamic> getOrders(
    String token,
    String url,
    String idUser,
    String status,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "id_user": idUser,
      "status": status,
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
        print("RESPONSE DATA GET ORDERS : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }

  static Future<dynamic> updateOrderItem(
    String token,
    String url,
    String idItem,
    int qty,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "id_item": idItem,
      "qty": qty,
    });

    Dio dio = Dio();
    dio.options.headers['x-username'] = xusername;
    dio.options.headers['x-password'] = xpassword;

    if (kDebugMode) {
      print("ENDPOINT URL : $url");
      print("FORM DATA UPDATE : token=$token, id_item=$idItem, qty=$qty");
    }

    final response = await dio.post(url, data: formData);

    if (kDebugMode) {
      print("RESPONSE STATUS CODE : ${response.statusCode}");
      print("RESPONSE DATA UPDATE ITEM : ${response.data}");
    }

    return response.data;
  }

  static Future<dynamic> deleteOrderItem(
    String token,
    String url,
    String idItem,
  ) async {
    FormData formData = FormData.fromMap({"token": token, "id_item": idItem});

    Dio dio = Dio();
    dio.options.headers['x-username'] = xusername;
    dio.options.headers['x-password'] = xpassword;

    if (kDebugMode) {
      print("ENDPOINT URL : $url");
      print("FORM DATA DELETE : token=$token, id_item=$idItem");
    }

    final response = await dio.post(url, data: formData);

    if (kDebugMode) {
      print("RESPONSE STATUS CODE : ${response.statusCode}");
      print("RESPONSE DATA DELETE ITEM : ${response.data}");
    }

    return response.data;
  }

  static Future<dynamic> createMidtransTransaction(
    String token,
    String url,
    String idUser,
    String idOrder,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "id_user": idUser,
      "id_order": idOrder,
    });

    Dio dio = Dio();
    dio.options.headers['x-username'] = xusername;
    dio.options.headers['x-password'] = xpassword;

    if (kDebugMode) print("ENDPOINT URL : $url");

    final response = await dio.post(url, data: formData);

    if (kDebugMode) {
      print("RESPONSE STATUS CODE : ${response.statusCode}");
      print("RESPONSE DATA MIDTRANS : ${response.data}");
    }

    return response.data;
  }

  static Future<dynamic> uploadBukti(
    String token,
    String url,
    String idOrder,
    String? filePath,
    Uint8List? fileBytes,
    String fileName,
  ) async {
    MultipartFile buktiFile;
    if (kIsWeb) {
      buktiFile = MultipartFile.fromBytes(fileBytes!, filename: fileName);
    } else {
      buktiFile = await MultipartFile.fromFile(filePath!, filename: fileName);
    }

    FormData formData = FormData.fromMap({
      "token": token,
      "id_order": idOrder,
      "bukti": buktiFile,
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
        print("RESPONSE DATA UPLOAD BUKTI : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }

  static Future<dynamic> getCs1Order(
    String token,
    String url,
    String status,
  ) async {
    FormData formData = FormData.fromMap({"token": token, "status": status});
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
        print("RESPONSE DATA GET ORDERS : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }

  static Future<dynamic> getCs1OrderDetail(
    String token,
    String url,
    int idOrder,
  ) async {
    FormData formData = FormData.fromMap({"token": token, "id_order": idOrder});
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
        print("RESPONSE DATA GET ORDERS : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }

  static Future<dynamic> cs1ExportOrdersCsv(
    String token,
    String url,
    String status,
  ) async {
    FormData formData = FormData.fromMap({"token": token, "status": status});
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
        print("RESPONSE DATA GET ORDERS : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }

  static Future<dynamic> cs1VerifyPayment(
    String token,
    String url,
    int idOrder,
    String action,
    String note,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "id_order": idOrder,
      "action": action,
      "note": note,
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
        print("RESPONSE DATA GET ORDERS : ${response.data}");
      }
      return response.data;
    } else {
      return response.data;
    }
  }

  static Future<dynamic> cs2UpdateStatus(
    String token,
    String url,
    int idOrder,
    String action,
  ) async {
    FormData formData = FormData.fromMap({
      "token": token,
      "id_order": idOrder,
      "action": action,
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
      print("RESPONSE DATA CS2 UPDATE : ${response.data}");
    }

    return response.data;
  }

  static Future<dynamic> downloadPdf(
    String token,
    String url,
    int idOrder,
  ) async {
    FormData formData = FormData.fromMap({"token": token, "id_order": idOrder});

    Dio dio = Dio();
    dio.options.headers['x-username'] = xusername;
    dio.options.headers['x-password'] = xpassword;

    if (kDebugMode) {
      print("ENDPOINT URL : $url");
    }

    final response = await dio.post(url, data: formData);

    if (kDebugMode) {
      print("RESPONSE STATUS CODE : ${response.statusCode}");
      print("RESPONSE DATA COMPLETE ORDER : ${response.data}");
    }

    return response.data;
  }
}
