import 'package:flutter/material.dart';

class HistoryNotifier extends ChangeNotifier {
  final BuildContext context;

  HistoryNotifier({required this.context});
  int page = 0;
  gantiPage(int value) {
    page = value;
    notifyListeners();
  }
}
