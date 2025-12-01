import 'package:flutter/material.dart';

class AuthNotifier extends ChangeNotifier {
  final BuildContext context;

  AuthNotifier({required this.context});
  int page = 0;
  gantiPage(int value) {
    page = value;
    notifyListeners();
  }
}
