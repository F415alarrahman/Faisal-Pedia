import 'package:flutter/material.dart';

import 'button_custom.dart';

class CustomDialog {
  static void loading(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Text("Sedang diproses...", style: TextStyle()),
        );
      },
    );
  }

  static void messageResponse(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$text", style: TextStyle()),
              SizedBox(height: 16),
              ButtonPrimary(onTap: () => Navigator.pop(context), name: "Ok"),
            ],
          ),
        );
      },
    );
  }
}
