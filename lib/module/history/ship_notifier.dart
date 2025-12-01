import 'dart:convert';
import 'package:faisal_pedia/models/order_models.dart';
import 'package:faisal_pedia/models/user_models.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/order_repository.dart';
import 'package:faisal_pedia/utils/dialog_custom.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ShipNotifier extends ChangeNotifier {
  final BuildContext context;

  ShipNotifier({required this.context}) {
    getProfile();
  }

  var isLoading = true;
  List<OrderModels> list = [];
  UserModels? users;

  getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      print("DATA ID : ${users!.idUser}");
      getOrder();
      notifyListeners();
    });
  }

  OrderModels? get currentOrder {
    if (list.isEmpty) return null;
    return list[0];
  }

  List<Item> get currentItems {
    final List<Item> items = [];
    for (final ord in list) {
      items.addAll(ord.items);
    }
    return items;
  }

  Future getOrder() async {
    list.clear();
    isLoading = true;
    notifyListeners();
    OrderRepository.getOrders(
      token,
      NetworkUrl.getOrders(),
      users!.idUser.toString(),
      "",
    ).then((value) {
      final data = value is String ? jsonDecode(value) : value;
      if (data['value'] == 1) {
        final List<dynamic> rows = data['data'] ?? [];
        for (final row in rows) {
          final status = (row['status'] ?? '').toString();
          if (status == "SHIP" || status == "SEDANG_DIPROSES") {
            final order = OrderModels.fromJson(row as Map<String, dynamic>);
            if (order.items.isEmpty) continue;
            list.add(order);
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }
        }
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> openInvoice(int index) async {
    if (index < 0 || index >= list.length) return;

    final order = list[index];
    final idOrder = order.idOrder.toString();

    final url = NetworkUrl.openInvoice(idOrder);

    if (kDebugMode) {
      print("OPEN INVOICE URL : $url");
    }

    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      CustomDialog.messageResponse(
        context,
        "Tidak bisa membuka / mengunduh invoice.",
      );
    }
  }

  Future<void> downloadInvoice(int index) async {
    if (index < 0 || index >= list.length) return;

    final order = list[index];
    final idOrder = order.idOrder.toString();

    final url = NetworkUrl.invoiceOrder(idOrder);

    if (kDebugMode) {
      print("OPEN INVOICE URL : $url");
    }

    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      CustomDialog.messageResponse(
        context,
        "Tidak bisa membuka / mengunduh invoice.",
      );
    }
  }
}
