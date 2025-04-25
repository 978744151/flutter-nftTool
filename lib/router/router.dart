import 'package:flutter/material.dart'; // 添加这行
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/shop_page.dart';

import '../pages/shop_detail.dart';
import '../pages/message_page.dart';
import '../pages/mine_page.dart';
import '../pages/blog_detail_page.dart';
import '../pages/login_page.dart';
import '../pages/shell_page.dart';
import '../pages/create_blog_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(); // 添加这行

final router = GoRouter(
  navigatorKey: _rootNavigatorKey, // 添加这行
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MessagePage(),
              routes: [
                GoRoute(
                  path: 'messageDetail/:id', // 修改为子路由
                  parentNavigatorKey: _rootNavigatorKey, // 添加这行
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return BlogDetailPage(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              builder: (context, state) => ShopPage(),
              routes: [
                GoRoute(
                  path: 'detail/:id', // 修改为子路由
                  parentNavigatorKey: _rootNavigatorKey, // 添加这行
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ShopDetail(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/create',
              builder: (context, state) => CreateBlogPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mine',
              builder: (context, state) => MinePage(),
            ),
          ],
        ),
      ],
    ),
    // 将博客详情页移到这里

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
