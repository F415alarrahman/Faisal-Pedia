import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class OrderModels {
  const OrderModels({
    required this.idOrder,
    required this.kodeOrder,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
    required this.midtransOrderId,
    required this.midtransSnapToken,
    required this.paymentProof,
    required this.items,
  });

  final int idOrder;
  final String kodeOrder;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final String status;
  final int totalAmount;
  final int itemCount;
  final String createdAt;
  final String updatedAt;
  final String midtransOrderId;
  final String midtransSnapToken;
  final String paymentProof;
  final List<Item> items;

  factory OrderModels.fromJson(Map<String, dynamic> json) => OrderModels(
    idOrder: json['id_order'] as int,
    kodeOrder: json['kode_order'].toString(),
    buyerName: json['buyer_name'].toString(),
    buyerPhone: json['buyer_phone'].toString(),
    buyerAddress: json['buyer_address'].toString(),
    status: json['status'].toString(),
    totalAmount: json['total_amount'] as int,
    itemCount: json['item_count'] as int,
    createdAt: json['created_at'].toString(),
    updatedAt: json['updated_at'].toString(),
    midtransOrderId: json['midtrans_order_id'].toString(),
    midtransSnapToken: json['midtrans_snap_token'].toString(),
    paymentProof: json['payment_proof'].toString(),
    items: (json['items'] as List? ?? [])
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id_order': idOrder,
    'kode_order': kodeOrder,
    'buyer_name': buyerName,
    'buyer_phone': buyerPhone,
    'buyer_address': buyerAddress,
    'status': status,
    'total_amount': totalAmount,
    'item_count': itemCount,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'midtrans_order_id': midtransOrderId,
    'midtrans_snap_token': midtransSnapToken,
    'payment_proof': paymentProof,
    'items': items.map((e) => e.toJson()).toList(),
  };

  OrderModels clone() => OrderModels(
    idOrder: idOrder,
    kodeOrder: kodeOrder,
    buyerName: buyerName,
    buyerPhone: buyerPhone,
    buyerAddress: buyerAddress,
    status: status,
    totalAmount: totalAmount,
    itemCount: itemCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
    midtransOrderId: midtransOrderId,
    midtransSnapToken: midtransSnapToken,
    paymentProof: paymentProof,
    items: items.map((e) => e.clone()).toList(),
  );

  OrderModels copyWith({
    int? idOrder,
    String? kodeOrder,
    String? buyerName,
    String? buyerPhone,
    String? buyerAddress,
    String? status,
    int? totalAmount,
    int? itemCount,
    String? createdAt,
    String? updatedAt,
    String? midtransOrderId,
    String? midtransSnapToken,
    String? paymentProof,
    List<Item>? items,
  }) => OrderModels(
    idOrder: idOrder ?? this.idOrder,
    kodeOrder: kodeOrder ?? this.kodeOrder,
    buyerName: buyerName ?? this.buyerName,
    buyerPhone: buyerPhone ?? this.buyerPhone,
    buyerAddress: buyerAddress ?? this.buyerAddress,
    status: status ?? this.status,
    totalAmount: totalAmount ?? this.totalAmount,
    itemCount: itemCount ?? this.itemCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    midtransOrderId: midtransOrderId ?? this.midtransOrderId,
    midtransSnapToken: midtransSnapToken ?? this.midtransSnapToken,
    paymentProof: paymentProof ?? this.paymentProof,
    items: items ?? this.items,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModels &&
          idOrder == other.idOrder &&
          kodeOrder == other.kodeOrder &&
          buyerName == other.buyerName &&
          buyerPhone == other.buyerPhone &&
          buyerAddress == other.buyerAddress &&
          status == other.status &&
          totalAmount == other.totalAmount &&
          itemCount == other.itemCount &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          midtransOrderId == other.midtransOrderId &&
          midtransSnapToken == other.midtransSnapToken &&
          paymentProof == other.paymentProof &&
          items == other.items;

  @override
  int get hashCode =>
      idOrder.hashCode ^
      kodeOrder.hashCode ^
      buyerName.hashCode ^
      buyerPhone.hashCode ^
      buyerAddress.hashCode ^
      status.hashCode ^
      totalAmount.hashCode ^
      itemCount.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      midtransOrderId.hashCode ^
      midtransSnapToken.hashCode ^
      paymentProof.hashCode ^
      items.hashCode;
}

@immutable
class Item {
  const Item({
    required this.idItem,
    required this.idProduct,
    required this.namaProduct,
    required this.harga,
    required this.qty,
    required this.subtotal,
    required this.thumbnail,
  });

  final int idItem;
  final int idProduct;
  final String namaProduct;
  final int harga;
  final int qty;
  final int subtotal;
  final String thumbnail;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    idItem: json['id_item'] as int,
    idProduct: json['id_product'] as int,
    namaProduct: json['nama_product'].toString(),
    harga: json['harga'] as int,
    qty: json['qty'] as int,
    subtotal: json['subtotal'] as int,
    thumbnail: json['thumbnail'].toString(),
  );

  Map<String, dynamic> toJson() => {
    'id_item': idItem,
    'id_product': idProduct,
    'nama_product': namaProduct,
    'harga': harga,
    'qty': qty,
    'subtotal': subtotal,
    'thumbnail': thumbnail,
  };

  Item clone() => Item(
    idItem: idItem,
    idProduct: idProduct,
    namaProduct: namaProduct,
    harga: harga,
    qty: qty,
    subtotal: subtotal,
    thumbnail: thumbnail,
  );

  Item copyWith({
    int? idItem,
    int? idProduct,
    String? namaProduct,
    int? harga,
    int? qty,
    int? subtotal,
    String? thumbnail,
  }) => Item(
    idItem: idItem ?? this.idItem,
    idProduct: idProduct ?? this.idProduct,
    namaProduct: namaProduct ?? this.namaProduct,
    harga: harga ?? this.harga,
    qty: qty ?? this.qty,
    subtotal: subtotal ?? this.subtotal,
    thumbnail: thumbnail ?? this.thumbnail,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          idItem == other.idItem &&
          idProduct == other.idProduct &&
          namaProduct == other.namaProduct &&
          harga == other.harga &&
          qty == other.qty &&
          subtotal == other.subtotal &&
          thumbnail == other.thumbnail;

  @override
  int get hashCode =>
      idItem.hashCode ^
      idProduct.hashCode ^
      namaProduct.hashCode ^
      harga.hashCode ^
      qty.hashCode ^
      subtotal.hashCode ^
      thumbnail.hashCode;
}
