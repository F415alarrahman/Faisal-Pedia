import 'package:faisal_pedia/models/index.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:flutter/material.dart';

class MenuNotifier extends ChangeNotifier {
  final BuildContext context;

  MenuNotifier({required this.context}) {
    if (MediaQuery.of(context).size.width > 500) {
      mobile = false;
    } else {
      mobile = true;
    }
    notifyListeners();
    getProfile();
  }
  UserModels? users;
  var mobile = false;
  getProfile() async {
    Pref().getUser().then((value) {
      users = value;
      notifyListeners();
    });
  }

  int page = 0;
  gantipage(int value) {
    page = value;
    notifyListeners();
  }
}
