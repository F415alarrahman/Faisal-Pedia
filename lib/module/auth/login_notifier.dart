import 'package:faisal_pedia/models/index.dart';
import 'package:faisal_pedia/module/menu/menu_page.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/auth_repository.dart';
import 'package:faisal_pedia/utils/dialog_custom.dart';
import 'package:faisal_pedia/utils/dialog_loading.dart';
import 'package:flutter/material.dart';

class LoginNotifier extends ChangeNotifier {
  final BuildContext context;

  LoginNotifier({required this.context});

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  var obscure = true;
  gantiobscure() async {
    obscure = !obscure;
    notifyListeners();
  }

  final keyForm = GlobalKey<FormState>();

  cek() {
    if (keyForm.currentState!.validate()) {
      simpan();
    }
  }

  simpan() async {
    DialogCustom().showLoading(context);
    AuthRepository.login(
          token,
          NetworkUrl.login(),
          email.text.trim(),
          password.text.trim(),
        )
        .then((value) {
          Navigator.pop(context);
          if (value['value'] == 1) {
            UserModels users = UserModels.fromJson(value);
            Pref().simpanUser(users);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
              (route) => false,
            );
          } else {
            CustomDialog.messageResponse(context, value['message']);
          }
        })
        .catchError((e) {
          Navigator.pop(context);
          CustomDialog.messageResponse(context, e.toString());
        });
  }
}
