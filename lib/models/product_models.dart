import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class ProductModels {

  const ProductModels({
    required this.idProduct,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.thumbnail,
    required this.gambarTambahan,
  });

  final int idProduct;
  final String nama;
  final String deskripsi;
  final int harga;
  final int stok;
  final String thumbnail;
  final List<dynamic> gambarTambahan;

  factory ProductModels.fromJson(Map<String,dynamic> json) => ProductModels(
    idProduct: json['id_product'] as int,
    nama: json['nama'].toString(),
    deskripsi: json['deskripsi'].toString(),
    harga: json['harga'] as int,
    stok: json['stok'] as int,
    thumbnail: json['thumbnail'].toString(),
    gambarTambahan: (json['gambar_tambahan'] as List? ?? []).map((e) => e as dynamic).toList()
  );
  
  Map<String, dynamic> toJson() => {
    'id_product': idProduct,
    'nama': nama,
    'deskripsi': deskripsi,
    'harga': harga,
    'stok': stok,
    'thumbnail': thumbnail,
    'gambar_tambahan': gambarTambahan.map((e) => e.toString()).toList()
  };

  ProductModels clone() => ProductModels(
    idProduct: idProduct,
    nama: nama,
    deskripsi: deskripsi,
    harga: harga,
    stok: stok,
    thumbnail: thumbnail,
    gambarTambahan: gambarTambahan.toList()
  );


  ProductModels copyWith({
    int? idProduct,
    String? nama,
    String? deskripsi,
    int? harga,
    int? stok,
    String? thumbnail,
    List<dynamic>? gambarTambahan
  }) => ProductModels(
    idProduct: idProduct ?? this.idProduct,
    nama: nama ?? this.nama,
    deskripsi: deskripsi ?? this.deskripsi,
    harga: harga ?? this.harga,
    stok: stok ?? this.stok,
    thumbnail: thumbnail ?? this.thumbnail,
    gambarTambahan: gambarTambahan ?? this.gambarTambahan,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is ProductModels && idProduct == other.idProduct && nama == other.nama && deskripsi == other.deskripsi && harga == other.harga && stok == other.stok && thumbnail == other.thumbnail && gambarTambahan == other.gambarTambahan;

  @override
  int get hashCode => idProduct.hashCode ^ nama.hashCode ^ deskripsi.hashCode ^ harga.hashCode ^ stok.hashCode ^ thumbnail.hashCode ^ gambarTambahan.hashCode;
}
