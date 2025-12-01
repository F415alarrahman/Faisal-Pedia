import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class UserModels {

  const UserModels({
    required this.idUser,
    required this.namaLengkap,
    required this.email,
    required this.role,
    required this.foto,
    required this.noHp,
    required this.alamat,
  });

  final int idUser;
  final String namaLengkap;
  final String email;
  final String role;
  final String foto;
  final String noHp;
  final String alamat;

  factory UserModels.fromJson(Map<String,dynamic> json) => UserModels(
    idUser: json['id_user'] as int,
    namaLengkap: json['nama_lengkap'].toString(),
    email: json['email'].toString(),
    role: json['role'].toString(),
    foto: json['foto'].toString(),
    noHp: json['no_hp'].toString(),
    alamat: json['alamat'].toString()
  );
  
  Map<String, dynamic> toJson() => {
    'id_user': idUser,
    'nama_lengkap': namaLengkap,
    'email': email,
    'role': role,
    'foto': foto,
    'no_hp': noHp,
    'alamat': alamat
  };

  UserModels clone() => UserModels(
    idUser: idUser,
    namaLengkap: namaLengkap,
    email: email,
    role: role,
    foto: foto,
    noHp: noHp,
    alamat: alamat
  );


  UserModels copyWith({
    int? idUser,
    String? namaLengkap,
    String? email,
    String? role,
    String? foto,
    String? noHp,
    String? alamat
  }) => UserModels(
    idUser: idUser ?? this.idUser,
    namaLengkap: namaLengkap ?? this.namaLengkap,
    email: email ?? this.email,
    role: role ?? this.role,
    foto: foto ?? this.foto,
    noHp: noHp ?? this.noHp,
    alamat: alamat ?? this.alamat,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is UserModels && idUser == other.idUser && namaLengkap == other.namaLengkap && email == other.email && role == other.role && foto == other.foto && noHp == other.noHp && alamat == other.alamat;

  @override
  int get hashCode => idUser.hashCode ^ namaLengkap.hashCode ^ email.hashCode ^ role.hashCode ^ foto.hashCode ^ noHp.hashCode ^ alamat.hashCode;
}
