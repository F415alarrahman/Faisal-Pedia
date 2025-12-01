import 'package:faisal_pedia/module/home/home_notifier.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/module/product/detail_product_page.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:faisal_pedia/utils/format_rupiah.dart';
import 'package:faisal_pedia/utils/images_path.dart';
import 'package:faisal_pedia/utils/pro_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faisal_pedia/module/cs1/home_cs1_page.dart';
import 'package:faisal_pedia/module/cs2/home_cs2_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeNotifier(context: context),
      child: Consumer<HomeNotifier>(
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  ImageAssets.logobrush,
                                  width: 80,
                                  height: 80,
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
                                      onChanged: (role) async {
                                        if (role == null) return;
                                        await value.changeRole(role);
                                        if (role == "Pembeli") {
                                        } else if (role == "CS 1") {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeCs1Page(),
                                            ),
                                          );
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
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: value.cariController,
                              onSubmitted: (e) => value.cariSekarang(),
                              decoration: InputDecoration(
                                fillColor: Colors.grey[100],
                                filled: true,
                                hintText: "Cari nama produk...",
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    value.clear();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: (value.list.length / 2).ceil(),
                          itemBuilder: (context, rowIndex) {
                            int i = rowIndex * 2;
                            int j = i + 1;
                            return value.isLoading
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailProductPage(
                                                        product: value.list[i],
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 280,
                                              margin: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    top: 70,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: colorPrimary,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 50,
                                                          ),
                                                          Text(
                                                            value.list[i].nama,
                                                            maxLines: 2,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            value
                                                                .list[i]
                                                                .deskripsi,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                formatRupiah(
                                                                  value
                                                                      .list[i]
                                                                      .harga,
                                                                ),
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      8,
                                                                    ),
                                                                decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: const Icon(
                                                                  Icons
                                                                      .arrow_forward,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Center(
                                                      child: Image.network(
                                                        "$assetsProducts/${value.list[i].thumbnail}",
                                                        height: 130,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: j < value.list.length
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailProductPage(
                                                              product:
                                                                  value.list[j],
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 280,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 6,
                                                        ),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          top: 70,
                                                          left: 0,
                                                          right: 0,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  colorPrimary,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 50,
                                                                ),
                                                                Text(
                                                                  value
                                                                      .list[j]
                                                                      .nama,
                                                                  maxLines: 2,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  value
                                                                      .list[j]
                                                                      .deskripsi,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      formatRupiah(
                                                                        value
                                                                            .list[j]
                                                                            .harga,
                                                                      ),
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            8,
                                                                          ),
                                                                      decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      child: const Icon(
                                                                        Icons
                                                                            .arrow_forward,
                                                                        size:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          right: 0,
                                                          child: Center(
                                                            child: Image.network(
                                                              "$assetsProducts/${value.list[j].thumbnail}",
                                                              height: 130,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ),
                                      ],
                                    ),
                                  );
                          },
                        ),
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
