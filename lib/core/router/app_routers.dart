// ignore_for_file: constant_identifier_names

enum AppRoutes {
  HomePage(absolutePath: '/', path: '/', name: 'home'),
  SearchPage(absolutePath: '/search', path: '/search', name: 'search'),
  FavoritePage(absolutePath: '/favorite', path: '/favorite', name: 'favorite'),
  MyPage(absolutePath: '/mypage', path: '/mypage', name: 'mypage'),
  LoginPage(absolutePath: '/login', path: '/login', name: 'login'),
  DetailPage(absolutePath: '/detail/:id', path: 'detail/:id', name: 'detail'),
  WritePage(absolutePath: '/write', path: '/write', name: 'write'),
  SplashPage(absolutePath: '/splash', path: '/splash', name: 'splash'),
  TempProfile(
    absolutePath: '/temp_profile',
    path: '/temp_profile',
    name: 'temp_profile',
  ),
  MyPageEdit(
    absolutePath: '/mypage/edit',
    path: '/mypage/edit',
    name: 'mypage_edit',
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
