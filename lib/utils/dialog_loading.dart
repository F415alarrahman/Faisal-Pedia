import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'images_path.dart';

class DialogCustom {
  void showLoading(BuildContext context) {
    Future.delayed(Duration.zero).then((value) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(ImageAssets.logo, height: 60),
                  ),
                  const SizedBox(height: 16),
                  const Text("Please wait..", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  const CupertinoActivityIndicator(radius: 20),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
