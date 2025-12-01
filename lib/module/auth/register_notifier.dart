import 'package:faisal_pedia/models/user_models.dart';
import 'package:faisal_pedia/module/home/home_page.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/pref/pref.dart';
import 'package:faisal_pedia/repository/auth_repository.dart';
import 'package:faisal_pedia/utils/dialog_custom.dart';
import 'package:faisal_pedia/utils/dialog_loading.dart';
import 'package:flutter/material.dart';

class RegisterNotifier extends ChangeNotifier {
  final BuildContext context;

  RegisterNotifier({required this.context});

  TextEditingController namaLengkap = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  var obscure = true;
  gantiobscure() async {
    obscure = !obscure;
    notifyListeners();
  }

  var obscureConfirm = true;
  confimGantiObscure() async {
    obscureConfirm = !obscureConfirm;
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
    AuthRepository.register(
          token,
          NetworkUrl.register(),
          namaLengkap.text.trim(),
          email.text.trim(),
          password.text.trim(),
        )
        .then((value) async {
          Navigator.pop(context);
          if (value['value'] == 1) {
            UserModels users = UserModels.fromJson(value);
            Pref().simpanUser(users);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
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
