import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/shop_page.dart';
import '../pages/message_page.dart';
import '../pages/mine_page.dart';
import '../pages/blog_detail_page.dart';
import '../pages/login_page.dart';
import '../widgets/keep_alive_wrapper.dart';
import '../pages/shell_page.dart';

final router = GoRouter(
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
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              builder: (context, state) => ShopPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/message',
              builder: (context, state) => const MessagePage(),
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
    // 其他非 tab 页面的路由
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/message/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlogDetailPage(id: id);
      },
    ),
  ],
);
