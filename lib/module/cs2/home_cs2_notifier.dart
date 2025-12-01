import 'dart:convert';

import 'package:faisal_pedia/models/order_models.dart';
import 'package:faisal_pedia/models/user_models.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/order_repository.dart';
import 'package:faisal_pedia/utils/dialog_loading.dart';
import 'package:faisal_pedia/utils/informationdialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCs2Notifier extends ChangeNotifier {
  final BuildContext context;

  HomeCs2Notifier({required this.context}) {
    getProfile();
  }

  UserModels? users;

  var isLoading = true;
  List<OrderModels> list = [];

  final List<String> roleList = ['Pembeli', 'CS 1', 'CS 2'];
  String currentRole = 'CS 2';

  Future<void> getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      print("DATA ID (CS2) : ${users!.idUser}");
      getOrder();
      notifyListeners();
    });
  }

  Future<void> changeRole(String role) async {
    currentRole = role;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_role', role);
  }

  getOrder() async {
    list.clear();
    isLoading = true;
    notifyListeners();
    OrderRepository.getCs1Order(token, NetworkUrl.getCs2Order(), "ALL").then((
      value,
    ) {
      final data = value is String ? jsonDecode(value) : value;

      if (data['value'] == 1) {
        for (Map<String, dynamic> i in data['data']) {
          final order = OrderModels.fromJson(i);
          if (order.items.isEmpty) continue;
          list.add(order);
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }

      isLoading = false;
      notifyListeners();
    });
  }

  exportData() {
    DialogCustom().showLoading(context);
    OrderRepository.cs1ExportOrdersCsv(
          token,
          NetworkUrl.cs2ExportOrdersCsv(),
          "ALL",
        )
        .then((value) {
          final data = value is String ? jsonDecode(value) : value;
          Navigator.pop(context);
          if (data['value'] == 1) {
            launchUrl(Uri.parse(data['url']));
          } else {
            informationDialog(context, "Warning", data['message']);
          }
        })
        .catchError((e) {
          Navigator.pop(context);
          informationDialog(context, "Error", e.toString());
        });
  }

  void _updateStatusCs2(int idOrder, String action, {String? successDefault}) {
    DialogCustom().showLoading(context);

    OrderRepository.cs2UpdateStatus(
          token,
          NetworkUrl.cs2UpdateStatus(),
          idOrder,
          action,
        )
        .then((value) {
          final data = value is String ? jsonDecode(value) : value;

          Navigator.pop(context);

          if ((data['value'] ?? 0) == 1) {
            getOrder();

            informationDialog(
              context,
              "Success",
              data['message']?.toString() ??
                  (successDefault ?? "Aksi berhasil diproses."),
            );
          } else {
            informationDialog(
              context,
              "Warning",
              data['message']?.toString() ?? "Gagal memproses aksi.",
            );
          }
        })
        .catchError((e) {
          Navigator.pop(context);
          informationDialog(context, "Error", e.toString());
        });
  }

  void processOrder(int idOrder) {
    _updateStatusCs2(
      idOrder,
      "PROCESS",
      successDefault: "Order berhasil diubah ke SEDANG_DIPROSES.",
    );
  }

  void shipOrder(int idOrder) {
    _updateStatusCs2(
      idOrder,
      "SHIP",
      successDefault: "Order berhasil diubah ke DIKIRIM.",
    );
  }

  void completeOrder(int idOrder) {
    _updateStatusCs2(
      idOrder,
      "COMPLETE",
      successDefault: "Order berhasil diselesaikan.",
    );
  }
}
