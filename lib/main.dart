import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// import 'dart:io' show Platform; // 用于检测平台

import 'package:go_router/go_router.dart';
import '/pages/home_page.dart';
// import '/pages/shop_page.dart';
import '/pages/message_page.dart';
import '/pages/mine_page.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

 // 强制设置 WebViewPlatform 实现
  if (WebViewPlatform.instance == null) {
    // 如果是 iOS 模拟器或设备，优先使用 WebKitWebView
    // if (Platform.isIOS || Platform.isMacOS) { // macOS 上运行 iOS 模拟器
    //   WebViewPlatform.instance = WebKitWebViewPlatform();
    // }
    // //  else if (Platform.isAndroid) {
    //   WebViewPlatform.instance = AndroidWebView();
    // } else {
    //   // 默认实现（例如 macOS 或其他平台）
    //   WebViewPlatform.instance = WebKitWebView(); // 或者根据需要选择
    // }
  }

  runApp(MyApp());
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    //  GoRoute(
    //    path: '/shop',
    //    builder: (context, state) => ShopPage(),
    //  ),
    GoRoute(
      path: '/message',
      builder: (context, state) => MessagePage(),
    ),
    GoRoute(
      path: '/mine',
      builder: (context, state) => MinePage(),
    ),
  ],
);
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomePage(),
//     );
//   }
// }