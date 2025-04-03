import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../pages/web_view_page.dart';

   class ShopPage extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       // 在页面加载后自动打开 WebView
       WidgetsBinding.instance.addPostFrameCallback((_) {
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => WebViewPage(
               url: 'https://back.gpyh.com/home',
               title: '数字藏品',
             ),
           ),
         );
       });

       return Scaffold(
         appBar: AppBar(title: Text('藏品')),
         body: Center(
          //  child: Column(
          //    mainAxisAlignment: MainAxisAlignment.center,
          //    children: [
          //      Text('加载数字藏品页面...'),
          //      SizedBox(height: 20),
          //      ElevatedButton(
          //        onPressed: () {
          //          // 手动打开 WebView 的按钮
          //          Navigator.of(context).push(
          //            MaterialPageRoute(
          //              builder: (context) => WebViewPage(
          //                url: 'http://8.155.53.210/#/nft/digitalCollectionPage',
          //                title: '数字藏品',
          //              ),
          //            ),
          //          );
          //        },
          //        child: Text('打开数字藏品'),
          //      ),
          //    ],
          //  ),
         ),
         bottomNavigationBar: const CustomBottomNavigation(
           currentIndex: 1, // 当前是藏品页
         ),
       );
     }
   }