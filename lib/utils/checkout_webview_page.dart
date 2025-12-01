import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CheckoutWebviewPage extends StatefulWidget {
  final String url;

  const CheckoutWebviewPage({super.key, required this.url});

  @override
  State<CheckoutWebviewPage> createState() => _CheckoutWebviewPageState();
}

class _CheckoutWebviewPageState extends State<CheckoutWebviewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    late PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = AndroidWebViewControllerCreationParams();
    }

    final WebViewController webController =
        WebViewController.fromPlatformCreationParams(params);

    webController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webController.loadRequest(Uri.parse(widget.url));

    controller = webController;
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: WebViewWidget(controller: controller),
    );
  }
}
