import 'package:faisal_pedia/module/auth/auth_page.dart';
import 'package:flutter/material.dart';

class OnBoardingNotifier extends ChangeNotifier {
  final BuildContext context;

  OnBoardingNotifier({required this.context});

  int page = 0;
  gantiPage(int value) {
    page = value;
    notifyListeners();
  }

  goTo() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AuthPage()));
  }
}
