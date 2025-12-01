import 'package:faisal_pedia/module/cart/cart_notifier.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:faisal_pedia/utils/format_rupiah.dart';
import 'package:faisal_pedia/utils/images_path.dart';
import 'package:faisal_pedia/utils/pro_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartNotifier(context: context),
      child: Consumer<CartNotifier>(
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: Colors.grey[300],
            body: SafeArea(
              child: Center(
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width > 600
                      ? 400
                      : MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: const Text(
                          "Keranjang",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      value.currentItems.isEmpty
                          ? Expanded(
                              child: Center(
                                child: Lottie.asset(
                                  LottieAssets.noData,
                                  repeat: false,
                                ),
                              ),
                            )
                          : value.isLoading
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProShimmer(height: 10, width: 200),
                                  const SizedBox(height: 4),
                                  ProShimmer(height: 10, width: 120),
                                  const SizedBox(height: 4),
                                  ProShimmer(height: 10, width: 100),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: value.currentItems.length,
                                itemBuilder: (context, index) {
                                  final item = value.currentItems[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: Image.network(
                                                "$assetsProducts/${item.thumbnail}",
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.namaProduct,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    formatRupiah(item.harga),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                    horizontal: 4,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (!value
                                                          .sudahCheckout) {
                                                        value.incQty(index);
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 22,
                                                      width: 22,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color:
                                                                Colors.yellow,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.add,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${value.qtyList.length > index ? value.qtyList[index] : item.qty}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (!value
                                                          .sudahCheckout) {
                                                        value.decQty(index);
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 22,
                                                      width: 22,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    value.openInvoice(index),
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Lihat Invoice (PDF)",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () =>
                                                  value.downloadInvoice(index),
                                              child: Container(
                                                height: 40,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "Print",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      value.currentItems.isEmpty
                          ? const SizedBox.shrink()
                          : Container(
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 50,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Subtotal",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          height: value.currentItems.length > 3
                                              ? 90
                                              : value.currentItems.length * 28,
                                          child: ListView.builder(
                                            itemCount:
                                                value.currentItems.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, i) {
                                              final item =
                                                  value.currentItems[i];
                                              final qty =
                                                  (i < value.qtyList.length)
                                                  ? value.qtyList[i]
                                                  : item.qty;
                                              final lineTotal = formatRupiah(
                                                item.harga * qty,
                                              );

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.namaProduct,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "x $qty",
                                                      style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      lineTotal,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Total",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              formatRupiah(
                                                value
                                                        .currentOrder
                                                        ?.totalAmount ??
                                                    0,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      18,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (value.sudahCheckout) {
                                          value.uploadBukti();
                                        } else {
                                          value.checkout();
                                        }
                                      },
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            value.sudahCheckout
                                                ? "Upload Bukti Pembayaran"
                                                : "Bayar Sekarang",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
