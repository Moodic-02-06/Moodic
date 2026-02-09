import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_page.dart';
import 'package:flutter_moodic/presentation/pages/login_page/login_view_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<UserEntity?>(loginViewModelProvider, (previous, next) {
      if (next != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomePage();
            },
          ),
        );
      }
    });

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
