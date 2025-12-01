import 'dart:convert';

import 'package:faisal_pedia/models/product_models.dart';
import 'package:faisal_pedia/models/user_models.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/order_repository.dart';
import 'package:faisal_pedia/repository/product_repository.dart';
import 'package:faisal_pedia/utils/dialog_custom.dart';
import 'package:faisal_pedia/utils/dialog_loading.dart';
import 'package:flutter/material.dart';

class DetailProductNotifier extends ChangeNotifier {
  final BuildContext context;
  final ProductModels product;

  DetailProductNotifier({required this.context, required this.product}) {
    getProfile();
  }

  UserModels? users;
  getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      print("DATA ID : ${users!.idUser}");
      getProduk();
      notifyListeners();
    });
  }

  var isLoading = true;
  int selectedImageIndex = -1;
  int qty = 1;

  void incQty() {
    if (qty >= product.stok) {
      CustomDialog.messageResponse(
        context,
        "Stok tidak mencukupi (maksimal ${product.stok})",
      );
      return;
    }

    qty++;
    notifyListeners();
  }

  void decQty() {
    if (qty > 1) {
      qty--;
      notifyListeners();
    }
  }

  void setSelectedImage(int index) {
    selectedImageIndex = index;
    notifyListeners();
  }

  String getMainImagePath(ProductModels product) {
    if (selectedImageIndex == -1 || product.gambarTambahan.isEmpty) {
      return product.thumbnail;
    }
    return product.gambarTambahan[selectedImageIndex];
  }

  List<ProductModels> list = [];
  Future getProduk() async {
    list.clear();
    isLoading = true;
    notifyListeners();

    ProductRepository.getProduct(
      token,
      NetworkUrl.getProduct(),
      users!.idUser.toString(),
    ).then((value) {
      final data = value is String ? jsonDecode(value) : value;
      if (data['value'] == 1) {
        for (Map<String, dynamic> i in data['data']) {
          list.add(ProductModels.fromJson(i));
        }
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
      }
    });
  }

  buatOrder() async {
    DialogCustom().showLoading(context);

    final items = <Map<String, dynamic>>[
      {"id_product": product.idProduct, "qty": qty},
    ];
    OrderRepository.createOrder(
          token,
          NetworkUrl.createOrder(),
          users!.idUser.toString(),
          users!.namaLengkap,
          users!.noHp,
          users!.alamat,
          items,
        )
        .then((value) async {
          Navigator.pop(context);
          final data = value is String ? jsonDecode(value) : value;

          if (data['value'] == 1) {
            CustomDialog.messageResponse(context, data['message']);
          } else {
            CustomDialog.messageResponse(context, data['message']);
          }
        })
        .catchError((e) {
          Navigator.pop(context);
          CustomDialog.messageResponse(context, e.toString());
        });
  }
}
