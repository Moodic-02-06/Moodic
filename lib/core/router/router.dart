import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
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
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier();

  // userProvider 상태 변화 감지 -> 라우터 갱신 알림
  ref.listen<AsyncValue<UserEntity?>>(userProvider, (previous, next) {
    notifier.notify();
  });

  return GoRouter(
    initialLocation: AppRoutes.SplashPage.absolutePath,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,

    redirect: (context, state) {
      // 리다이렉트 내부에서 최신 상태 조회
      final userState = ref.read(userProvider);
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.SplashPage.absolutePath;
      final isLoggingIn = location == AppRoutes.LoginPage.absolutePath;
      final isTempProfile = location == AppRoutes.TempProfile.absolutePath;

      // 1. [로딩 처리 최적화]
      if (userState.isLoading || userState.isRefreshing) {
        if (isSplash) return null;
        return null;
      }

      final user = userState.value;
      final isLoggedIn = user != null;

      // 2. 비로그인 상태 처리
      if (!isLoggedIn) {
        // 스플래시 페이지인 경우
        if (isSplash) {
          return null;
        }

        // 로그인 페이지면 유지
        if (isLoggingIn) return null;

        // 그 외 모든 경로는 로그인 페이지로 리다이렉트
        return AppRoutes.LoginPage.absolutePath;
      }

      // 3. 로그인 상태 처리
      if (isLoggedIn) {
        // [처음 방문 유저]
        if (user.isFirst) {
          // 이미 임시 프로필 페이지라면 가만히 있고, 아니면 이동
          if (isTempProfile) return null;
          return AppRoutes.TempProfile.absolutePath;
        }

        // [기존 유저]
        // 스플래시, 로그인, 임시프로필 페이지에 머물러 있다면 홈으로 보냄
        if (isSplash || isLoggingIn || isTempProfile) {
          // 예외: 로그아웃/탈퇴 액션이 있는 경우 스플래시 접근 허용
          // (로그인 된 상태에서도 스플래시로 가서 로그아웃을 진행해야 함)
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
                  context.push(AppRoutes.WritePage.absolutePath);
                } else {
                  int branchIndex = index;
                  if (index > 2) {
                    branchIndex = index - 1;
                  }

                  // 마이페이지(branchIndex 3)로 이동 시 데이터 새로고침
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
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.FavoritePage.path,
                builder: (context, state) => const LikePage(),
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
        path: AppRoutes.DetailPage.absolutePath,
        name: AppRoutes.DetailPage.name,
        builder: (context, state) {
          final post = state.extra as Post?;

          // 만약 데이터가 없다면 (새로고침, 에러 등) 예외 처리
          if (post == null) {
            // 리스트 페이지로 튕겨내거나, 에러 화면을 보여줌
            return const Scaffold(
              body: Center(child: Text("데이터를 불러올 수 없습니다. 다시 시도해주세요.")),
            );
          }

          // 데이터가 있을 때만 정상적으로 전달
          return DetailPage(post: post);
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
        path: AppRoutes.MyPageEdit.path,
        name: AppRoutes.MyPageEdit.name,
        builder: (context, state) => const MyPageEdit(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.SearchResult.path,
        name: AppRoutes.SearchResult.name,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is MoodType) {
            return SearchResultPage(mood: extra);
          } else if (extra is Music) {
            return SearchResultPage(music: extra);
          }
          // fallback: 잘못된 접근
          return const Scaffold(body: Center(child: Text('잘못된 검색 요청입니다.')));
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
