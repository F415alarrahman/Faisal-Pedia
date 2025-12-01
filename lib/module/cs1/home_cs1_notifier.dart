import 'dart:convert';

import 'package:faisal_pedia/models/index.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/order_repository.dart';
import 'package:faisal_pedia/utils/dialog_loading.dart';
import 'package:faisal_pedia/utils/informationdialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCs1Notifier extends ChangeNotifier {
  final BuildContext context;

  HomeCs1Notifier({required this.context}) {
    getProfile();
  }

  UserModels? users;
  var isLoading = true;
  List<OrderModels> list = [];

  getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      print("DATA ID (CS1) : ${users!.idUser}");
      initRole();
      getOrder();
      notifyListeners();
    });
  }

  List<String> roleList = ["Pembeli", "CS 1", "CS 2"];

  String currentRole = "CS 1";

  initRole() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('selected_role') ?? "CS 1";

    currentRole = savedRole;
    notifyListeners();
  }

  changeRole(String role) async {
    currentRole = role;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_role', role);
  }

  getOrder() async {
    list.clear();
    isLoading = true;
    notifyListeners();

    OrderRepository.getCs1Order(
      token,
      NetworkUrl.getCs1Order(),
      "MENUNGGU_VERIFIKASI_CS1",
    ).then((value) {
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
      NetworkUrl.cs1ExportOrdersCsv(),
      "MENUNGGU_VERIFIKASI_CS1",
    ).then((value) {
      final data = value is String ? jsonDecode(value) : value;
      Navigator.pop(context);
      if (data['value'] == 1) {
        launchUrl(Uri.parse(data['url']));
      } else {
        informationDialog(context, "Warning", data['message']);
      }
    });
  }

  void verifyOrder(int idOrder, String action, {String note = ''}) {
    DialogCustom().showLoading(context);

    OrderRepository.cs1VerifyPayment(
          token,
          NetworkUrl.cs1VerifyOrder(),
          idOrder,
          action,
          note,
        )
        .then((value) {
          final data = value is String ? jsonDecode(value) : value;
          Navigator.pop(context);
          if (data['value'] == 1) {
            getOrder();
            informationDialog(
              context,
              "Success",
              data['message'] ?? "Aksi berhasil diproses.",
            );
          } else {
            informationDialog(
              context,
              "Warning",
              data['message'] ?? "Gagal memproses aksi.",
            );
          }
        })
        .catchError((e) {
          Navigator.pop(context); // tutup dialog loading kalau error
          informationDialog(context, "Error", e.toString());
        });
  }

  void approveOrder(int idOrder) {
    verifyOrder(idOrder, "ACCEPT");
  }

  void rejectOrder(int idOrder, String note) {
    verifyOrder(idOrder, "REJECT", note: note);
  }
}
