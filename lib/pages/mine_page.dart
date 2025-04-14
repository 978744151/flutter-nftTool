// lib/pages/mine_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('我的')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: Text('个人信息'),
          ),
        ],
      ),
      //   bottomNavigationBar: CustomBottomNavigation(
      //   currentIndex: 3, // 当前是首页
      // ),
    );
  }
}
