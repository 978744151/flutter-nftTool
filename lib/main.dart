import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import './utils/http_client.dart';

// import 'dart:io' show Platform; // 用于检测平台

import 'router/router.dart'; // 添加这行

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 强制设置 WebViewPlatform 实现
  // if (WebViewPlatform.instance == null) {
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
  // }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // 移除了不存在的 navigatorKey 参数
      routerConfig: router,
      title: 'NFT ONCE',
      theme: ThemeData(
        primaryColor: const Color(0xfffbc2eb),
        // 设置 TextButton 主题
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 199, 46, 102),
            foregroundColor: Colors.white,
          ),
        ),
        // 设置 ElevatedButton 主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        // 设置 OutlinedButton 主题
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(176, 224, 230, 1),
          ),
        ),
        scaffoldBackgroundColor: Colors.white, // 设置默认背景颜色为白色
      ),
    );
  }
}
