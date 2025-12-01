import 'package:faisal_pedia/models/product_models.dart';
import 'package:faisal_pedia/network/network.dart';
import 'package:faisal_pedia/module/product/detail_product_notifier.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:faisal_pedia/utils/format_rupiah.dart';
import 'package:faisal_pedia/utils/images_path.dart';
import 'package:faisal_pedia/utils/pro_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailProductPage extends StatelessWidget {
  final ProductModels product;
  const DetailProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailProductNotifier(context: context, product: product),
      child: Consumer<DetailProductNotifier>(
        builder: (context, value, child) => Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: Center(
              child: Container(
                color: colorPrimary,
                width: MediaQuery.of(context).size.width > 600
                    ? 400
                    : MediaQuery.of(context).size.width,
                child: value.isLoading
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 340,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          height: 36,
                                          width: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Product Details",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 36, width: 36),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    "$assetsProducts/${value.getMainImagePath(product)}",
                                    height: 220,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        ImageAssets.logobrush,
                                        height: 220,
                                        fit: BoxFit.contain,
                                      );
                                    },
                                  ),
                                ),

                                Positioned(
                                  right: 16,
                                  top: 80,
                                  child: SizedBox(
                                    height: 70 * 3 + 12 * 2 + 8 * 2,
                                    width: 56 + 8 * 2,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: product.gambarTambahan.length,
                                      itemBuilder: (context, index) {
                                        final imgPath =
                                            product.gambarTambahan[index];
                                        final isSelected =
                                            value.selectedImageIndex == index;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              value.setSelectedImage(
                                                index,
                                              ); // ✅ ganti gambar utama
                                            },
                                            child: Container(
                                              height: 70,
                                              width: 56,
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.yellow
                                                      : Colors
                                                            .white, // highlight
                                                  width: 2,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: Image.network(
                                                "$assetsProducts/$imgPath",
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        ImageAssets.logobrush,
                                                        fit: BoxFit.contain,
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: colorPrimary,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.nama,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: value.decQty,
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 16,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                value.qty.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              InkWell(
                                                onTap: value.incQty,
                                                child: Container(
                                                  height: 22,
                                                  width: 22,
                                                  decoration: BoxDecoration(
                                                    color: Colors.yellow,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Jumlah Stok : ${product.stok}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "Description",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      product.deskripsi,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                            color: colorPrimary,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatRupiah(product.harga * value.qty),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => value.buatOrder(),
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Add to Cart",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
