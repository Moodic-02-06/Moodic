import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_page.dart';
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

            Expanded(
              flex: 5,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await user.loginWithGoogle();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 40),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/image.png',
                            width: 20,
                            height: 20,
                          ),
                          Text(
                            '구글로그인',
                            style: AppTextStyles.bodyPrimary16w600.copyWith(
                              color: AppColors.gray100,
                            ),
                          ),
                          SizedBox(width: 20, height: 20),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      await user.loginWithkakao();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 40),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/image copy.png',
                            width: 20,
                            height: 20,
                          ),

                          Text(
                            '카카오로그인',
                            style: AppTextStyles.bodyPrimary16w600.copyWith(
                              color: AppColors.primary600,
                            ),
                          ),
                          SizedBox(width: 20, height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
