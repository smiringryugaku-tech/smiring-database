import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/app/routes.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';
import 'package:smiring_database/presentation/pages/home/home_page.dart';
import 'package:smiring_database/presentation/pages/members/members_page.dart';
import 'package:smiring_database/presentation/pages/profile/profile_page.dart';
import 'package:smiring_database/presentation/pages/sign_in/forgot_password_page.dart';
import 'package:smiring_database/presentation/pages/sign_in/reset_password_page.dart';
import 'package:smiring_database/presentation/pages/sign_in/sign_in_page.dart';
import 'package:smiring_database/presentation/pages/sign_in/sign_up_page.dart';
import 'package:smiring_database/presentation/pages/welcome/welcome_page.dart';
import 'package:smiring_database/presentation/widgets/layout/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true, 
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),

    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final path = state.uri.path;

      // 【最優先】パスワードリセット画面は、どんな状態でもそのまま表示許可
      if (path == AppRoutes.resetPassword) return null;

      // 公開ページの定義
      final isPublicRoute = path == AppRoutes.welcome || 
                            path == AppRoutes.signIn || 
                            path == AppRoutes.signUp || 
                            path == AppRoutes.forgotPassword;

      // 未ログインの場合
      if (session == null) {
        if (path == AppRoutes.welcome) return null; // Welcomeページはそのまま
        return isPublicRoute ? null : AppRoutes.signIn;
      }

      // ログイン済みの場合
      // 公開ページ（ログイン画面など）にいたらHomeへ飛ばす
      if (isPublicRoute) return AppRoutes.home;

      return null;
    },

    routes: [
      // 1. ログイン前
      GoRoute(path: AppRoutes.welcome, builder: (_, __) => const WelcomePage()),
      GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInPage()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpPage()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(path: AppRoutes.resetPassword, builder: (_, __) => const ResetPasswordPage()),

      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child); 
        },
        routes: [
          // この中に定義したルートが MainLayout の中身として表示されます
          GoRoute(
            path: AppRoutes.home, 
            builder: (context, state) => const HomePage(),
          ),

          GoRoute(
            path: AppRoutes.profile, 
            builder: (context, state) => const ProfilePage(),
          ),

          GoRoute(
            path: AppRoutes.members, 
            builder: (context, state) => const MembersPage(),
          ),
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
