import 'package:faisal_pedia/module/cs1/home_cs1_page.dart';
import 'package:faisal_pedia/module/cs2/home_cs2_notifier.dart';
import 'package:faisal_pedia/module/menu/menu_page.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:faisal_pedia/utils/format_rupiah.dart';
import 'package:faisal_pedia/utils/images_path.dart';
import 'package:faisal_pedia/utils/pro_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomeCs2Page extends StatelessWidget {
  const HomeCs2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeCs2Notifier(context: context),
      child: Consumer<HomeCs2Notifier>(
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  ImageAssets.logobrush,
                                  width: 60,
                                  height: 60,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Dashboard CS 2",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
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
                                      onChanged: (role) {
                                        if (role == null || role == "CS 2") {
                                          return;
                                        }
                                        value.changeRole(role);
                                        if (role == "Pembeli") {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MenuPage(),
                                            ),
                                          );
                                        } else if (role == "CS 1") {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeCs1Page(),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => value.exportData(),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Export Data CSV",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
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
                            child: value.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : value.list.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Belum ada order untuk diproses.",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  )
                                : ListView.builder(
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
                                      final status = order.status;
                                      final canProcess =
                                          status == 'MENUNGGU_DIPROSES_CS2';
                                      final canShip =
                                          status == 'MENUNGGU_DIPROSES_CS2' ||
                                          status == 'SEDANG_DIPROSES';
                                      final canComplete = status == 'DIKIRIM';
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorPrimary,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              order.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              children: order.items.map((item) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8.0,
                                                      ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // thumbnail
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
                                                            const EdgeInsets.all(
                                                              6,
                                                            ),
                                                        child: Image.network(
                                                          "$assetsProducts/${item.thumbnail}",
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      // info item
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item.namaProduct,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
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
                                                                const Text(
                                                                  "Harga",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Text(
                                                                  formatRupiah(
                                                                    item.harga,
                                                                  ),
                                                                  style: const TextStyle(
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
                                                                const Text(
                                                                  "Jumlah",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Text(
                                                                  "${item.qty}",
                                                                  style: const TextStyle(
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
                                                                const Text(
                                                                  "Subtotal",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Text(
                                                                  formatRupiah(
                                                                    item.subtotal,
                                                                  ),
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  formatRupiah(
                                                    order.totalAmount,
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: canProcess
                                                        ? () => value
                                                              .processOrder(
                                                                order.idOrder,
                                                              )
                                                        : null,
                                                    child: Container(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: canProcess
                                                            ? Colors.white
                                                            : Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          "Proses",
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
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: canShip
                                                        ? () => value.shipOrder(
                                                            order.idOrder,
                                                          )
                                                        : null,
                                                    child: Container(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: canShip
                                                            ? Colors.yellow
                                                            : Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          "Kirim",
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
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: canComplete
                                                        ? () => value
                                                              .completeOrder(
                                                                order.idOrder,
                                                              )
                                                        : null,
                                                    child: Container(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: canComplete
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          "Selesai",
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
                                              ],
                                            ),
                                          ],
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
