import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

import 'no_internet_page.dart';
import 'server_down_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinTalkApp());
}

class FinTalkApp extends StatelessWidget {
  const FinTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;

  bool noInternet = false;
  bool serverDown = false;
  bool isLoading = true;

  final String baseUrl = "https://10.70.29.39:443/FinTalk/FinTalk.aspx";

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  final List<String> noRefreshPages = ["/LoginScreen.aspx"];
  final List<String> noBackPages = ["/LoginScreen.aspx"];

  @override
  void initState() {
    super.initState();

    // Status bar color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFD800),
      statusBarIconBrightness: Brightness.dark,
    ));

    _disableScreenshot();
    _checkInternet();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });

    pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        webViewController?.reload();
      },
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _disableScreenshot() async {
    await FlutterWindowManagerPlus.addFlags(
      FlutterWindowManagerPlus.FLAG_SECURE,
    );
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ].request();
  }

  void _checkInternet() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        noInternet = results.contains(ConnectivityResult.none) &&
            results.length == 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Custom pages
    if (noInternet) return const NoInternetPage();
    if (serverDown) return const ServerDownPage();

    return WillPopScope(
      onWillPop: () async {
        if (webViewController != null) {
          final canGoBack = await webViewController!.canGoBack();
          final url = await webViewController!.getUrl();

          if (url != null &&
              noBackPages.any((page) => url.toString().contains(page))) {
            return false;
          }

          if (canGoBack) {
            webViewController!.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFD800),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(baseUrl)),
                pullToRefreshController: pullToRefreshController,
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  supportZoom: false,
                  builtInZoomControls: false,
                  displayZoomControls: false,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  allowFileAccess: true,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    isLoading = true;
                  });
                },
                onLoadStop: (controller, url) {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    isLoading = false;
                  });

                  if (url != null &&
                      noRefreshPages
                          .any((page) => url.toString().contains(page))) {
                    pullToRefreshController.setEnabled(false);
                  } else {
                    pullToRefreshController.setEnabled(true);
                  }
                },
                onLoadError: (controller, url, code, message) {
                  setState(() {
                    serverDown = true;
                    isLoading = false;
                  });
                },
                shouldOverrideUrlLoading: (controller, nav) async {
                  final uri = nav.request.url;

                  if (uri != null &&
                      (uri.host.contains("instagram") ||
                          uri.host.contains("facebook"))) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onReceivedServerTrustAuthRequest:
                    (controller, challenge) async {
                  return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED,
                  );
                },
              ),

              // ✅ Loader
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD800),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
