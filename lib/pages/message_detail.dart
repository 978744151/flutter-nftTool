final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/user/:id',
      builder: (context, state) {
        return UserScreen(id: state.params['id']!);
      },
    ),
  ],
);

MaterialApp.router(
  routerConfig: router,
);
