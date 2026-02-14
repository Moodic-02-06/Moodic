import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/data/repository/auth_repository_impl.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
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
        await authRepo.signOut().timeout(const Duration(seconds: 3));
      } else if (widget.action == 'delete') {
        try {
          // 회원탈퇴는 3초 제한
          await authRepo.deleteAccount().timeout(const Duration(seconds: 3));
        } catch (e) {
          debugPrint("회원탈퇴 실패 (타임아웃 또는 에러): $e");
          // 탈퇴 실패 시에도 로그아웃 처리하여 로그인 화면으로 이동 유도 (2초 제한)
          try {
            await authRepo.signOut().timeout(const Duration(seconds: 2));
          } catch (e) {
            // 로그아웃도 실패하면 무시하고 진행
          }
        }
      }

      // 상태 갱신을 확실하게 하기 위해 provider invalidate
      ref.invalidate(userProvider);
      // 잠시 대기하여 스트림이 null을 방출하도록 유도
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint("스플래시 액션 실패: $e");
    } finally {
      // provider invalidate는 위에서 처리했으나, 혹시 모를 상황 대비
      if (widget.action != null) {
        ref.invalidate(userProvider);
      }
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
