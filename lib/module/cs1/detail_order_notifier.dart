import 'dart:convert';

import 'package:faisal_pedia/models/order_models.dart';
import 'package:faisal_pedia/models/user_models.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/order_repository.dart';
import 'package:flutter/material.dart';

class DetailOrderNotifier extends ChangeNotifier {
  final BuildContext context;
  final OrderModels order;

  DetailOrderNotifier({required this.context, required this.order}) {
    getProfile();
  }

  UserModels? users;
  var isLoading = true;
  List<OrderModels> list = [];

  getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      print("DATA ID (CS1) : ${users!.idUser}");
      getOrderDetail();
      notifyListeners();
    });
  }

  getOrderDetail() async {
    list.clear();
    isLoading = true;
    notifyListeners();

    OrderRepository.getCs1OrderDetail(
      token,
      NetworkUrl.getCs1Order(),
      order.idOrder,
    ).then((value) {
      final data = value is String ? jsonDecode(value) : value;
      if (data['value'] == 1) {
        for (Map<String, dynamic> i in data['data']) {
          final order = OrderModels.fromJson(i);
          if (order.items.isEmpty) continue;
          list.add(order);
        }
      }
      isLoading = false;
      notifyListeners();
    });
  }
}
