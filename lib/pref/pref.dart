import 'package:faisal_pedia/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pref {
  static String idUser = "id_user";
  static String namaLengkap = "nama_lengkap";
  static String email = "email";
  static String role = "role";
  static String foto = "foto";
  static String isLoggedIn = "is_logged_in";
  static String noHp = "no_hp";
  static String alamat = "alamat";

  simpanUser(UserModels user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt(Pref.idUser, user.idUser);
    await pref.setString(Pref.namaLengkap, user.namaLengkap);
    await pref.setString(Pref.email, user.email);
    await pref.setString(Pref.role, user.role);
    await pref.setString(Pref.foto, user.foto);
    await pref.setString(Pref.noHp, user.noHp);
    await pref.setString(Pref.alamat, user.alamat);
    await pref.setBool(Pref.isLoggedIn, true);
  }

  Future<UserModels?> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    final id = pref.getInt(Pref.idUser) ?? 0;
    if (id == 0) return null;

    return UserModels(
      idUser: id,
      namaLengkap: pref.getString(Pref.namaLengkap) ?? "",
      email: pref.getString(Pref.email) ?? "",
      role: pref.getString(Pref.role) ?? "",
      foto: pref.getString(Pref.foto) ?? "",
      noHp: pref.getString(Pref.noHp) ?? "",
      alamat: pref.getString(Pref.alamat) ?? "",
    );
  }

  Future<String> getRole() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(Pref.role) ?? "";
  }

  Future<bool> getIsLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(Pref.isLoggedIn) ?? false;
  }

  logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(Pref.idUser);
    await pref.remove(Pref.namaLengkap);
    await pref.remove(Pref.email);
    await pref.remove(Pref.role);
    await pref.remove(Pref.foto);
    await pref.remove(Pref.noHp);
    await pref.remove(Pref.alamat);

    await pref.setBool(Pref.isLoggedIn, false);
  }

  static const _keyRoleMode = "role_mode";

  Future<void> setRoleMode(String role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyRoleMode, role);
  }

  Future<String?> getRoleMode() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyRoleMode);
  }
}
