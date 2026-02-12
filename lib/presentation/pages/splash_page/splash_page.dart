import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';

import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // 2초 뒤에 실행하라고 예약하는 부분
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        // 화면이 아직 떠있는지 확인 (안전장치)
        context.go(AppRoutes.LoginPage.path); // 로그인 페이지로 이동
      }
    });
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
                child: Image.asset(
                  'assets/images/logo.png',
                  width: double.infinity,
                  height: 600,
                ),
              ),
            ),

            Expanded(flex: 5, child: Column(children: [])),
          ],
        ),
      ),
    );
  }
}
