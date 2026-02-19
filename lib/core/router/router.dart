import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_page.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_page.dart';
import 'package:flutter_moodic/presentation/pages/like_page/like_page.dart';
import 'package:flutter_moodic/presentation/pages/login_page/login_page.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';
import 'package:flutter_moodic/presentation/pages/my_page_edit/my_page_edit.dart';
import 'package:flutter_moodic/presentation/pages/search_page/search_page.dart';
import 'package:flutter_moodic/presentation/pages/search_result_page/search_result_page.dart';
import 'package:flutter_moodic/presentation/pages/splash_page/splash_page.dart';
import 'package:flutter_moodic/presentation/pages/temp_profile/temp_profile.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page.dart';
import 'package:flutter_moodic/presentation/pages/follow_list_page/follow_list_page.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier();

  // userProvider 상태 변화 감지 → 라우터 갱신 알림
  ref.listen<AsyncValue<UserEntity?>>(userProvider, (previous, next) {
    notifier.notify();
  });

  return GoRouter(
    initialLocation: AppRoutes.SplashPage.absolutePath,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,

    redirect: (context, state) {
      final userState = ref.read(userProvider);
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.SplashPage.absolutePath;
      final isLoggingIn = location == AppRoutes.LoginPage.absolutePath;
      final isTempProfile = location == AppRoutes.TempProfile.absolutePath;

      if (userState.isLoading || userState.isRefreshing) return null;

      final user = userState.value;
      final isLoggedIn = user != null;

      if (!isLoggedIn) {
        if (isSplash || isLoggingIn) return null;
        return AppRoutes.LoginPage.absolutePath;
      }

      if (isLoggedIn) {
        if (user.isFirst) {
          if (isTempProfile) return null;
          return AppRoutes.TempProfile.absolutePath;
        }
        if (isSplash || isLoggingIn || isTempProfile) {
          final action = state.uri.queryParameters['action'];
          if (isSplash && (action == 'logout' || action == 'delete')) {
            return null;
          }
          return AppRoutes.HomePage.absolutePath;
        }
      }

      return null;
    },

    routes: [
      // ──────────────────────────────────────────
      // 1. 바텀 네비게이션 쉘
      // ──────────────────────────────────────────
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
                  context.push(AppRoutes.WritePage.absolutePath);
                } else {
                  int branchIndex = index;
                  if (index > 2) branchIndex = index - 1;

                  // 마이페이지 탭으로 이동 시 데이터 새로고침
                  if (branchIndex == 3) {
                    ref.invalidate(myPageViewModelProvider);
                  }

                  navigationShell.goBranch(branchIndex);
                }
              },
            ),
          );
        },
        branches: [
          // ── Home 탭 ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.HomePage.path,
                name: AppRoutes.HomePage.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // ── Search 탭 ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.SearchPage.path,
                name: AppRoutes.SearchPage.name,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),

          // ── Favorite(좋아요) 탭 ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.FavoritePage.path,
                builder: (context, state) => const LikePage(),
              ),
            ],
          ),

          // ── MyPage 탭 ──
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

      // ──────────────────────────────────────────
      // 2. 전체 화면 라우트 (바텀바 위에 오버레이)
      //    root navigator에 등록 → 바텀바가 가려짐
      // ──────────────────────────────────────────

      // DetailPage: postId만 pathParam으로 받음 (extra 불필요)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.DetailPage.path,
        name: AppRoutes.DetailPage.name,
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return DetailPage(postId: postId);
        },
      ),

      // SearchResult: queryParam 기반 (type, value, title, artwork)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.SearchResult.path,
        name: AppRoutes.SearchResult.name,
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'mood';
          final value = state.uri.queryParameters['value'] ?? '';
          final musicTitle = state.uri.queryParameters['title'];
          final musicArtwork = state.uri.queryParameters['artwork'];
          return SearchResultPage(
            type: type,
            value: value,
            musicTitle: musicTitle,
            musicArtwork: musicArtwork,
          );
        },
      ),

      // MyPageEdit
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.MyPageEdit.path,
        name: AppRoutes.MyPageEdit.name,
        builder: (context, state) => const MyPageEdit(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.WritePage.path,
        name: AppRoutes.WritePage.name,
        builder: (context, state) {
          final post = state.extra as Post?;
          return WritePage(post: post);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.LoginPage.path,
        name: AppRoutes.LoginPage.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.FollowList.absolutePath,
        name: AppRoutes.FollowList.name,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final initialTab = state.uri.queryParameters['initialTab'] ?? '0';
          return FollowListPage(
            userId: userId,
            initialTabIndex: int.parse(initialTab),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.SplashPage.path,
        name: AppRoutes.SplashPage.name,
        builder: (context, state) {
          final action = state.uri.queryParameters['action'];
          return SplashPage(action: action);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.TempProfile.path,
        name: AppRoutes.TempProfile.name,
        builder: (context, state) => const TempProfile(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.UserPage.absolutePath,
        name: AppRoutes.UserPage.name,
        builder: (context, state) {
          final userId = state.pathParameters['userId'];
          return MyPage(userId: userId);
        },
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
