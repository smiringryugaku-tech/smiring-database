import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/app/routes.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';
import 'package:smiring_database/presentation/pages/home/home_page.dart';
import 'package:smiring_database/presentation/pages/sign_in/sign_in_page.dart';
import 'package:smiring_database/presentation/pages/sign_in/sign_up_page.dart';
import 'package:smiring_database/presentation/pages/welcome/welcome_page.dart';
import 'package:smiring_database/presentation/widgets/layout/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true, 
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),

    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final path = state.uri.path;
      final isAuthRoute = path == AppRoutes.welcome || path == AppRoutes.signIn || path == AppRoutes.signUp;
      
      if (session == null && !isAuthRoute) return AppRoutes.signIn;
      if (session != null && isAuthRoute && path != AppRoutes.welcome) return AppRoutes.home;

      return null;
    },

    routes: [
      // 1. ログイン前
      GoRoute(path: AppRoutes.welcome, builder: (_, __) => const WelcomePage()),
      GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInPage()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpPage()),

      ShellRoute(
        // ここで child (中身のページ) が渡ってきます
        builder: (context, state, child) {
          return MainLayout(child: child); 
        },
        routes: [
          // この中に定義したルートが MainLayout の中身として表示されます
          GoRoute(
            path: AppRoutes.home, 
            builder: (context, state) => const HomePage(), // ここは普通にPageを返す
          ),
          
          // 他の認証後ページもここに追加
          // GoRoute(
          //   path: '/profile',
          //   builder: (context, state) => const ProfilePage(),
          // ),
        ],
      ),
    ],
  );
});

/// Supabase auth stream → GoRouterのrefreshに使う
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
