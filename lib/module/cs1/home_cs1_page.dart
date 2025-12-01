import 'package:faisal_pedia/module/cs1/detail_order_page.dart';
import 'package:faisal_pedia/module/cs1/home_cs1_notifier.dart';
import 'package:faisal_pedia/module/cs2/home_cs2_page.dart';
import 'package:faisal_pedia/module/menu/menu_page.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:faisal_pedia/utils/format_rupiah.dart';
import 'package:faisal_pedia/utils/images_path.dart';
import 'package:faisal_pedia/utils/pro_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomeCs1Page extends StatelessWidget {
  const HomeCs1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeCs1Notifier(context: context),
      child: Consumer<HomeCs1Notifier>(
        builder: (context, value, child) => Scaffold(
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
                    Container(
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  ImageAssets.logobrush,
                                  width: 80,
                                  height: 80,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Dashboard CS 1",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: 120,
                                  child: InkWell(
                                    onTap: () => value.exportData(),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Export Invoice",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: value.currentRole,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      items: value.roleList.map((role) {
                                        return DropdownMenuItem<String>(
                                          value: role,
                                          child: Text(role),
                                        );
                                      }).toList(),
                                      onChanged: (role) async {
                                        if (role == null) return;
                                        await value.changeRole(role);
                                        if (role == "Pembeli") {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MenuPage(),
                                            ),
                                          );
                                        } else if (role == "CS 1") {
                                        } else if (role == "CS 2") {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeCs2Page(),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    value.list.isEmpty
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
                              itemCount: value.list.length,
                              itemBuilder: (context, index) {
                                final order = value.list[index];
                                if (order.items.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailOrderPage(order: order),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: order.items.map((item) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 70,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            18,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Image.network(
                                                      "$assetsProducts/${item.thumbnail}",
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.namaProduct,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Harga",
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              formatRupiah(
                                                                item.harga,
                                                              ),
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Jumlah",
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              "${item.qty}",
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Subtotal",
                                                              style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              formatRupiah(
                                                                item.subtotal,
                                                              ),
                                                              style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 6),
                                        const Divider(
                                          color: Colors.white24,
                                          thickness: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Total",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              formatRupiah(order.totalAmount),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => value.approveOrder(
                                                  order.idOrder,
                                                ),
                                                child: Container(
                                                  height: 40,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Terima",
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
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  value.rejectOrder(
                                                    order.idOrder,
                                                    "Barang tidak sesuai bukti pembayaran",
                                                  );
                                                },
                                                child: Container(
                                                  height: 40,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Tolak",
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
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
