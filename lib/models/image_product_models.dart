import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class ImageProductModels {

  const ImageProductModels({
    required this.idProduct,
    required this.nama,
    required this.thumbnail,
    required this.gambarTambahan,
  });

  final int idProduct;
  final String nama;
  final String thumbnail;
  final List<dynamic> gambarTambahan;

  factory ImageProductModels.fromJson(Map<String,dynamic> json) => ImageProductModels(
    idProduct: json['id_product'] as int,
    nama: json['nama'].toString(),
    thumbnail: json['thumbnail'].toString(),
    gambarTambahan: (json['gambar_tambahan'] as List? ?? []).map((e) => e as dynamic).toList()
  );
  
  Map<String, dynamic> toJson() => {
    'id_product': idProduct,
    'nama': nama,
    'thumbnail': thumbnail,
    'gambar_tambahan': gambarTambahan.map((e) => e.toString()).toList()
  };

  ImageProductModels clone() => ImageProductModels(
    idProduct: idProduct,
    nama: nama,
    thumbnail: thumbnail,
    gambarTambahan: gambarTambahan.toList()
  );


  ImageProductModels copyWith({
    int? idProduct,
    String? nama,
    String? thumbnail,
    List<dynamic>? gambarTambahan
  }) => ImageProductModels(
    idProduct: idProduct ?? this.idProduct,
    nama: nama ?? this.nama,
    thumbnail: thumbnail ?? this.thumbnail,
    gambarTambahan: gambarTambahan ?? this.gambarTambahan,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is ImageProductModels && idProduct == other.idProduct && nama == other.nama && thumbnail == other.thumbnail && gambarTambahan == other.gambarTambahan;

  @override
  int get hashCode => idProduct.hashCode ^ nama.hashCode ^ thumbnail.hashCode ^ gambarTambahan.hashCode;
}
