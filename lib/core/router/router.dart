import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_page.dart';
import 'package:flutter_moodic/presentation/pages/login_page/login_page.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page.dart';
import 'package:flutter_moodic/presentation/pages/splash_page/splash_page.dart';
import 'package:flutter_moodic/presentation/pages/temp_profile/temp_profile.dart';
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
    (_, _) => refreshNotifier.value = !refreshNotifier.value,
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
      final isTempProfile =
          state.matchedLocation == AppRoutes.TempProfile.absolutePath;

      // 1. 로그인 안 됨
      if (!isLoggedIn) {
        // 현재 위치가 로그인/스플래시가 아니면 로그인 페이지로 강제 이동
        if (!isLoggingIn && !isSplash) return AppRoutes.LoginPage.absolutePath;
        return null;
      }

      // 2. 로그인 됨
      if (isLoggedIn) {
        // 처음 방문한 유저(isFirst == true)인 경우
        if (user.isFirst) {
          // 이미 자기소개 페이지에 있다면 그대로 두고, 아니면 이동
          if (!isTempProfile) return AppRoutes.TempProfile.absolutePath;
          return null;
        }

        // 처음 방문이 아닌데 스플래시나 로그인 페이지에 머물러 있다면 홈으로
        if (isLoggingIn || isSplash) {
          return AppRoutes.HomePage.absolutePath;
        }
      }

      return null;
    },
    routes: [
      // 1. 바텀 네비게이션이 있는 쉘
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: navigationShell.currentIndex <= 1
                  ? navigationShell.currentIndex
                  : navigationShell.currentIndex + 1,
              onTap: (index) {
                if (index == 2) {
                  // 중앙 버튼은 페이지 이동만
                  context.push(AppRoutes.WritePage.absolutePath);
                } else {
                  // index 0, 1은 그대로 0, 1번 브랜치
                  // index 3, 4는 한 칸씩 당겨서 2, 3번 브랜치
                  int branchIndex = index;
                  if (index > 2) {
                    branchIndex = index - 1;
                  }
                  navigationShell.goBranch(branchIndex);
                }
              },
            ),
          );
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.HomePage.path,
                name: AppRoutes.HomePage.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.SearchPage.path,
                name: AppRoutes.SearchPage.name,
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.FavoritePage.path,
                name: AppRoutes.FavoritePage.name,
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
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
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.SplashPage.path,
        name: AppRoutes.SplashPage.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.TempProfile.path,
        name: AppRoutes.TempProfile.name,
        builder: (context, state) => const TempProfile(),
      ),
    ],
  );
});
