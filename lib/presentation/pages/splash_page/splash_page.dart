import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/data/repository/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  final String? action;
  const SplashPage({super.key, this.action});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    _processActionAndNavigate();
  }

  Future<void> _processActionAndNavigate() async {
    // 1. 최소 대기 시간 (애니메이션 등)
    final minDelay = Future.delayed(const Duration(seconds: 3));

    // 2. 액션 실행 (로그아웃 / 탈퇴)
    final authRepo = ref.read(authRepositoryProvider);
    try {
      if (widget.action == 'logout') {
        await authRepo.signOut();
      } else if (widget.action == 'delete') {
        await authRepo.deleteAccount();
      }
    } catch (e) {
      debugPrint("스플래시 액션 실패: $e");
    }

    // 3. 작업 완료 및 최소 시간 대기 후 이동
    await minDelay;

    if (mounted) {
      // 로그아웃 상태이므로 라우터가 LoginPage로 리다이렉트 처리함
      context.go(AppRoutes.LoginPage.absolutePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 14,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: double.infinity,
                    height: 600,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}
