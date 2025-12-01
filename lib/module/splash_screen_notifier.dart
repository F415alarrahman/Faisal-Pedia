import 'package:faisal_pedia/models/index.dart';
import 'package:faisal_pedia/module/menu/menu_page.dart';
import 'package:faisal_pedia/module/on_boarding_page.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:flutter/material.dart';

class SplashScreenNotifier extends ChangeNotifier {
  final BuildContext context;

  SplashScreenNotifier({required this.context}) {
    getProfile();
  }

  UserModels? users;
  getProfile() async {
    Future.delayed(Duration(seconds: 2)).then((e) {
      Pref().getUser().then((value) {
        users = value;
        final userId = users?.idUser ?? 0;
        if (userId != 0) {
          login();
        } else {
          nothing();
        }
        notifyListeners();
      });
    });
  }

  login() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MenuPage()),
      (route) => false,
    );
  }

  nothing() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnBoardingPage()),
      (route) => false,
    );
  }
}
