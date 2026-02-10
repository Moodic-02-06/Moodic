import 'package:flutter/material.dart';
import 'package:flutter_moodic/presentation/pages/login_page/login_view_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.listen<UserEntity?>(loginViewModelProvider, (previous, next) {
    //   if (next != null) {
    //     // Router가 AuthState 변화를 감지하여 자동으로 리다이렉트하므로 수동 이동 불필요
    //   }
    // });

    ref.watch(loginViewModelProvider);
    final user = ref.read(loginViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 600),
            GestureDetector(
              onTap: () async {
                await user.loginWithGoogle();
              },
              child: Container(
                width: 250,
                height: 40,
                color: Colors.white,
                child: Text('구글로그인'),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                await user.loginWithkakao();
              },
              child: Container(
                width: 250,
                height: 40,
                color: Colors.amber,
                child: Text('카카오로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
