import 'package:faisal_pedia/module/on_boarding_notifier.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:faisal_pedia/utils/images_path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnBoardingNotifier(context: context),
      child: Consumer<OnBoardingNotifier>(
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
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 260,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(40),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(ImageAssets.logo, height: 60),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 72),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Selamat datang di Faisal Pedia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Toko online terpercaya dengan berbagai produk berkualitas dan layanan terbaik untuk memenuhi kebutuhan Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => value.goTo(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: colorPrimary,
                                ),
                                child: Text(
                                  "Lanjutkan",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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
