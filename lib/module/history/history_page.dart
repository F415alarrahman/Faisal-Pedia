import 'package:faisal_pedia/module/history/complete_page.dart';
import 'package:faisal_pedia/module/history/history_notifier.dart';
import 'package:faisal_pedia/module/history/proses_page.dart';
import 'package:faisal_pedia/module/history/ship_page.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryNotifier(context: context),
      child: Consumer<HistoryNotifier>(
        builder: (context, value, child) => Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: Center(
              child: Container(
                color: colorPrimary,
                width: MediaQuery.of(context).size.width > 600
                    ? 400
                    : MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Lihat Riwayat Pesanan Anda di\nFaisalPedia",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 24.0,
                      ),
                      child: Text(
                        "Kelola dan tinjau pesanan sebelumnya dengan mudah melalui halaman riwayat pesanan kami",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 24,
                            right: 24,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => value.gantiPage(0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          color: value.page == 0
                                              ? Colors.white
                                              : Colors.grey[200],
                                        ),
                                        child: Text(
                                          "Diproses",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: value.page == 0
                                                ? Colors.black
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => value.gantiPage(1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          color: value.page == 1
                                              ? Colors.white
                                              : Colors.grey[200],
                                        ),
                                        child: Text(
                                          "Dikirim",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: value.page == 1
                                                ? Colors.black
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => value.gantiPage(2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          color: value.page == 2
                                              ? Colors.white
                                              : Colors.grey[200],
                                        ),
                                        child: Text(
                                          "Selesai",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: value.page == 2
                                                ? Colors.black
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 80,
                            child: value.page == 0
                                ? ProsesPage()
                                : value.page == 1
                                ? ShipPage()
                                : CompletePage(),
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
