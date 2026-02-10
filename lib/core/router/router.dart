import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_page.dart';
import 'package:flutter_moodic/presentation/pages/login_page/login_page.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final userState = ref.watch(userProvider);
  final refreshNotifier = ValueNotifier<bool>(false);

  ref.listen(
    userProvider,
    (_, __) => refreshNotifier.value = !refreshNotifier.value,
  );

  return GoRouter(
    initialLocation: AppRoutes.HomePage.absolutePath,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      if (userState.isLoading) return null;

      final user = userState.value;
      final isLoggedIn = user != null;

      final isLoggingIn =
          state.matchedLocation == AppRoutes.LoginPage.absolutePath;
      final isSplash =
          state.matchedLocation == AppRoutes.SplashPage.absolutePath;

      // 로그인 안 됨 -> 로그인 페이지로
      if (!isLoggedIn) {
        if (!isLoggingIn && !isSplash) return AppRoutes.LoginPage.absolutePath;
        return null;
      }

      // 로그인 됨 -> 스플래시나 로그인 페이지에 있다면 홈/자기소개로
      if (isLoggedIn && (isLoggingIn || isSplash)) {
        // 닉네임이 비어있는지 확인하여 처음 온 유저인지 판단
        // (UserEntity의 nickname이 빈 문자열("")로 들어온다고 가정할 때)
        final bool isFirstTime = user.nickname.isEmpty;

        if (isFirstTime) {
          return AppRoutes.TempProfile.absolutePath; // 자기소개(닉네임 설정) 페이지로
        }
        return AppRoutes.HomePage.absolutePath; // 닉네임이 있으면 홈으로
      }

      return null;
    },
    routes: [
      // 1. 바텀 네비게이션이 있는 쉘 (appRouter에 있던 내용 이동)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                if (index == 2) {
                  context.push(AppRoutes.WritePage.absolutePath);
                } else {
                  navigationShell.goBranch(index);
                }
              },
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.HomePage.path,
                name: AppRoutes.HomePage.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // ... 나머지 브랜치들(Search, Favorite, MyPage) 그대로 복사
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.MyPage.path,
                name: AppRoutes.MyPage.name,
                builder: (context, state) => const MyPage(),
              ),
            ],
          ),
        ],
      ),

      // 2. 바텀바가 없는 전체 화면 경로들
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.WritePage.path,
        name: AppRoutes.WritePage.name,
        builder: (context, state) => const WritePage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.LoginPage.path,
        name: AppRoutes.LoginPage.name,
        builder: (context, state) => const LoginPage(),
      ),
      // SplashPage와 자기소개(tem) 페이지도 여기에 추가하세요!
    ],
  );
});
