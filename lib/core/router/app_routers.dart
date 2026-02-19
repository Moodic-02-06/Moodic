// ignore_for_file: constant_identifier_names

/// 앱의 모든 라우트 경로 정의
///
/// nested route 구조에 따라 path와 absolutePath가 다를 수 있습니다.
/// - path: GoRoute에 등록하는 상대 경로 (nested route에서 사용)
/// - absolutePath: 직접 navigate 시 사용하는 절대 경로
///
/// [하위 라우트 구조]
/// / (Home)
///   └── detail/:id
/// /search
///   └── result?type=...&value=...
/// /favorite
///   └── detail/:id
/// /mypage
///   ├── edit
///   └── detail/:id
enum AppRoutes {
  HomePage(absolutePath: '/', path: '/', name: 'home'),
  SearchPage(absolutePath: '/search', path: '/search', name: 'search'),
  FavoritePage(absolutePath: '/favorite', path: '/favorite', name: 'favorite'),
  MyPage(absolutePath: '/mypage', path: '/mypage', name: 'mypage'),
  LoginPage(absolutePath: '/login', path: '/login', name: 'login'),

  // 탭별 하위 라우트로 등록됨 (name은 공통으로 사용)
  DetailPage(absolutePath: '/detail/:id', path: 'detail/:id', name: 'detail'),

  WritePage(absolutePath: '/write', path: '/write', name: 'write'),
  SplashPage(absolutePath: '/splash', path: '/splash', name: 'splash'),
  TempProfile(
    absolutePath: '/temp_profile',
    path: '/temp_profile',
    name: 'temp_profile',
  ),

  // MyPage 탭 하위 라우트 (/mypage/edit)
  MyPageEdit(absolutePath: '/mypage/edit', path: 'edit', name: 'mypage_edit'),

  // Search 탭 하위 라우트 (/search/result)
  SearchResult(
    absolutePath: '/search/result',
    path: 'result',
    name: 'search_result',
  ),

  UserPage(
    absolutePath: '/user/:userId',
    path: '/user/:userId',
    name: 'user_page',
  ),
  FollowList(
    absolutePath: '/follow_list/:userId',
    path: '/follow_list/:userId',
    name: 'follow_list',
  );

  final String absolutePath;
  final String path;
  final String name;

  const AppRoutes({
    required this.absolutePath,
    required this.path,
    required this.name,
  });
}
