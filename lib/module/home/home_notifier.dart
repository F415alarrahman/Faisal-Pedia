import 'dart:convert';

import 'package:faisal_pedia/models/index.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:faisal_pedia/module/cs1/home_cs1_page.dart';
import 'package:faisal_pedia/module/cs2/home_cs2_page.dart';

class HomeNotifier extends ChangeNotifier {
  final BuildContext context;

  HomeNotifier({required this.context}) {
    getProfile();
  }

  UserModels? users;

  getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      print("DATA ID : ${users!.idUser}");
      initRole();
      getProduk();
      notifyListeners();
    });
  }

  var isLoading = true;

  List<String> roleList = ["Pembeli", "CS 1", "CS 2"];

  String currentRole = "Pembeli";

  initRole() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('selected_role') ?? "Pembeli";
    currentRole = savedRole;
    notifyListeners();
    if (savedRole == "CS 1") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeCs1Page()),
      );
    } else if (savedRole == "CS 2") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeCs2Page()),
      );
    }
  }

  changeRole(String role) async {
    currentRole = role;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_role', role);
  }

  TextEditingController cariController = TextEditingController();
  cariSekarang() {
    isLoading = true;
    list.clear();
    notifyListeners();

    ProductRepository.searchProduct(
      token,
      NetworkUrl.searchProduct(),
      cariController.text.toUpperCase(),
    ).then((value) {
      final data = value is String ? jsonDecode(value) : value;
      if (data['value'] == 1) {
        for (Map<String, dynamic> i in data['data']) {
          list.add(ProductModels.fromJson(i));
        }
        list.sort((a, b) => a.nama.compareTo(b.nama));

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
      }
    });
  }

  clear() {
    cariController.clear();
    notifyListeners();
  }

  List<ProductModels> list = [];

  getProduk() async {
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
}
