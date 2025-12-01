import 'dart:convert';

import 'package:faisal_pedia/models/index.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/order_repository.dart';
import 'package:faisal_pedia/repository/product_repository.dart';
import 'package:faisal_pedia/utils/dialog_custom.dart';
import 'package:faisal_pedia/utils/dialog_loading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CartNotifier extends ChangeNotifier {
  final BuildContext context;

  CartNotifier({required this.context}) {
    getProfile();
  }

  UserModels? users;

  bool sudahCheckout = false;

  getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      print("DATA ID : ${users!.idUser}");
      getOrder();
      getProduk();
      notifyListeners();
    });
  }

  List<ProductModels> listProduk = [];
  Map<int, int> stokMap = {};

  Future getProduk() async {
    listProduk.clear();
    stokMap.clear();

    ProductRepository.getProduct(
      token,
      NetworkUrl.getProduct(),
      users!.idUser.toString(),
    ).then((value) {
      final data = value is String ? jsonDecode(value) : value;
      if (data['value'] == 1) {
        for (Map<String, dynamic> i in data['data']) {
          final p = ProductModels.fromJson(i);
          listProduk.add(p);

          stokMap[p.idProduct] = p.stok;
        }
      }
    });
  }

  var isLoading = true;
  List<OrderModels> list = [];
  List<int> qtyList = [];
  OrderModels? get currentOrder {
    if (list.isEmpty) return null;
    return list[0];
  }

  int get currentTotalAmount {
    final ord = currentOrder;
    if (ord == null) return 0;
    return ord.totalAmount;
  }

  List<Item> get currentItems {
    final ord = currentOrder;
    if (ord == null) return [];
    return ord.items;
  }

  Future getOrder() async {
    list.clear();
    qtyList.clear();
    isLoading = true;
    sudahCheckout = false;
    notifyListeners();

    OrderRepository.getOrders(
      token,
      NetworkUrl.getOrders(),
      users!.idUser.toString(),
      "MENUNGGU_UPLOAD_BUKTI",
    ).then((value) {
      final data = value is String ? jsonDecode(value) : value;

      if (data['value'] == 1) {
        for (Map<String, dynamic> i in data['data']) {
          final order = OrderModels.fromJson(i);
          if (order.items.isEmpty) continue;
          list.add(order);
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          for (final it in order.items) {
            qtyList.add(it.qty);
          }
          break;
        }
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void incQty(int index) {
    if (sudahCheckout) return;
    if (list.isEmpty) return;

    final order = list[0];
    if (index < 0 || index >= order.items.length) return;

    final item = order.items[index];
    final idOrderItem = item.idItem.toString();

    final idProduct = item.idProduct;
    final maxStok = stokMap[idProduct] ?? 999999;

    final oldQty = qtyList[index];
    final newQty = oldQty + 1;

    if (newQty > maxStok) {
      CustomDialog.messageResponse(
        context,
        "Stok tidak mencukupi (maksimal $maxStok)",
      );
      return;
    }

    qtyList[index] = newQty;
    notifyListeners();

    OrderRepository.updateOrderItem(
      token,
      NetworkUrl.updateOrderItem(),
      idOrderItem,
      newQty,
    ).then((value) {}).catchError((e) {
      qtyList[index] = oldQty;
      notifyListeners();
      print(e);
    });
  }

  void decQty(int index) {
    if (sudahCheckout) return;
    if (list.isEmpty) return;

    final order = list[0];
    if (index < 0 || index >= order.items.length) return;

    final item = order.items[index];
    final idOrderItem = item.idItem.toString();

    final oldQty = qtyList[index];
    final newQty = oldQty - 1;

    if (newQty <= 0) {
      final removedOrderItemId = idOrderItem;

      order.items.removeAt(index);
      qtyList.removeAt(index);
      notifyListeners();

      OrderRepository.deleteOrderItem(
        token,
        NetworkUrl.deleteOrderItem(),
        removedOrderItemId,
      ).catchError((e) {
        print(e);
        getOrder();
      });
    } else {
      qtyList[index] = newQty;
      notifyListeners();

      OrderRepository.updateOrderItem(
        token,
        NetworkUrl.updateOrderItem(),
        idOrderItem,
        newQty,
      ).catchError((e) {
        qtyList[index] = oldQty;
        notifyListeners();
        print(e);
      });
    }
  }

  int get total {
    if (list.isEmpty) return 0;
    final order = list[0];

    int sum = 0;
    for (int i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      final qty = (i < qtyList.length) ? qtyList[i] : item.qty;
      sum += item.harga * qty;
    }
    return sum;
  }

  checkout() async {
    if (list.isEmpty) {
      CustomDialog.messageResponse(context, "Tidak ada order untuk dibayar!");
      return;
    }

    final order = list[0];
    final idOrder = order.idOrder.toString();

    DialogCustom().showLoading(context);

    try {
      final value = await OrderRepository.createMidtransTransaction(
        token,
        NetworkUrl.createMidtransTransaction(),
        users!.idUser.toString(),
        idOrder,
      );

      Navigator.pop(context);

      final data = value is String ? jsonDecode(value) : value;

      if (kDebugMode) {
        print("CREATE MIDTRANS TRANSACTION RESP : $data");
      }

      if (data['value'] == 1 &&
          (data['snap_token'] ?? '').toString().isNotEmpty) {
        final snapToken = data['snap_token'].toString();
        final snapUrl =
            "https://app.sandbox.midtrans.com/snap/v3/redirection/$snapToken";

        if (kDebugMode) {
          print("MIDTRANS SNAP URL : $snapUrl");
        }

        sudahCheckout = true;
        notifyListeners();

        final uri = Uri.parse(snapUrl);

        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (!ok) {
          CustomDialog.messageResponse(
            context,
            "Tidak bisa membuka halaman pembayaran.",
          );
        }
      } else {
        CustomDialog.messageResponse(
          context,
          data['message'] ?? "Gagal membuat transaksi Midtrans.",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      CustomDialog.messageResponse(context, "Terjadi kesalahan: $e");
    }
  }

  uploadBukti() async {
    if (list.isEmpty) {
      CustomDialog.messageResponse(context, "Order tidak ditemukan!");
      return;
    }

    final order = list[0];
    final idOrder = order.idOrder.toString();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      CustomDialog.messageResponse(context, "Tidak ada foto yang dipilih.");
      return;
    }

    final file = result.files.single;
    final String fileName = file.name;
    final String? filePath = file.path;
    final Uint8List? fileBytes = file.bytes;
    DialogCustom().showLoading(context);

    OrderRepository.uploadBukti(
          token,
          NetworkUrl.uploadBukti(),
          idOrder,
          filePath,
          fileBytes,
          fileName,
        )
        .then((value) async {
          Navigator.pop(context);

          final data = value is String ? jsonDecode(value) : value;

          if (data['value'] == 1) {
            CustomDialog.messageResponse(
              context,
              data['message'] ?? "Bukti pembayaran berhasil diupload!",
            );
            getOrder();
          } else {
            CustomDialog.messageResponse(
              context,
              data['message'] ?? "Gagal upload bukti pembayaran",
            );
          }
        })
        .catchError((e) {
          Navigator.pop(context);
          CustomDialog.messageResponse(context, e.toString());
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
