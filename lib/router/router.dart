import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/shop_page.dart';
import '../pages/message_page.dart';
import '../pages/mine_page.dart';
import '../pages/blog_detail_page.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return child;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/shop',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: ShopPage(),
          ),
        ),
        GoRoute(
          path: '/message',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const MessagePage(),
          ),
        ),
        GoRoute(
          path: '/message/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!; // 使用非空断言，因为我们确定 id 参数存在
            return BlogDetailPage(
              id: id,
            );
          },
        ),
        GoRoute(
          path: '/mine',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: MinePage(),
          ),
        ),
      ],
    ),
  ],
);
