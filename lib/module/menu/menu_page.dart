import 'package:faisal_pedia/module/cart/cart_page.dart';
import 'package:faisal_pedia/module/history/history_page.dart';
import 'package:faisal_pedia/module/home/home_page.dart';
import 'package:faisal_pedia/module/menu/menu_notifier.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:faisal_pedia/utils/images_path.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuNotifier(context: context),
      child: Consumer<MenuNotifier>(
        builder: (context, value, child) => SafeArea(
          child: Scaffold(
            body: Container(
              color: Colors.grey[200],
              child: Center(
                child: SizedBox(
                  width: value.mobile ? double.infinity : 400,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 60,
                        child: value.page == 0
                            ? const HomePage()
                            : value.page == 1
                            ? const HistoryPage()
                            : const CartPage(),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            border: Border(
                              top: BorderSide(
                                width: 1,
                                color: Colors.grey[300] ?? Colors.transparent,
                              ),
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => value.gantipage(0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        value.page == 0
                                            ? LottieAssets.home
                                            : LottieAssets.homeUnselect,
                                        height: 38,
                                      ),
                                      Text(
                                        "Beranda",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: value.page == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => value.gantipage(1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        value.page == 1
                                            ? LottieAssets.history
                                            : LottieAssets.historyunselect,
                                        height: 38,
                                      ),
                                      Text(
                                        "Riwayat",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: value.page == 1
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: InkWell(
                            onTap: () => value.gantipage(3),
                            child: Container(
                              height: 50,
                              width: 50,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: value.page == 3
                                      ? Colors.black
                                      : Colors.black26,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Lottie.asset(LottieAssets.shoppingCart),
                            ),
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
      ),
    );
  }
}
