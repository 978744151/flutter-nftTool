   // lib/pages/mine_page.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';

   class MinePage extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text('我的')),
         body: Center(child: Text('这是我的页面')),
          bottomNavigationBar: CustomBottomNavigation(
          currentIndex: 3, // 当前是首页
        ),
       );
     }
   }