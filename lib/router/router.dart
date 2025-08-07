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
import '../pages/settings_page.dart';
import '../pages/nft/nft_detail.dart';
import '../pages/nft/nft_edition_detail.dart';
import 'package:bot_toast/bot_toast.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(); // 添加这行

final router = GoRouter(
  navigatorKey: _rootNavigatorKey, // 添加这行
  observers: [BotToastNavigatorObserver()],

  initialLocation: '/',
  redirect: (context, state) {
    // 如果访问根路径，重定向到message页面
    if (state.location == '/') {
      return '/';
    }
    return null; // 不重定向
  },
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
              builder: (context, state) => HomePage(),
              routes: [
                GoRoute(
                  path: 'nftDetail/:id', // 修改为子路由
                  parentNavigatorKey: _rootNavigatorKey, // 添加这行
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return NftDetail(id: id);
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
              path: '/message',
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
              path: '/mine',
              builder: (context, state) => MinePage(),
            ),
          ],
        ),
      ],
    ),
    // 将博客详情页移到这里

    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/nftEditionDetail/:id/:nftId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final nftId = state.pathParameters['nftId']!;
        // 这里需要根据id获取edition数据，暂时传空map，后续可根据实际需求获取数据
        return NftEditionDetail(
          id: id,
          nftId: nftId,
        );
      },
    ),
  ],
);
