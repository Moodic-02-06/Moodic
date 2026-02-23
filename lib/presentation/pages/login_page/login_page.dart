import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/login_page/login_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(
                              'https://sparkling-wallaby-fec.notion.site/2026-02-20-30d3afd0fa6e80228ac2ff232936a751',
                            );
                            if (!await launchUrl(url)) {
                              debugPrint("Could not launch $url");
                            }
                          },
                          child: Text(
                            "이용약관",
                            style: AppTextStyles.bodySecondary12w500.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(
                              'https://sparkling-wallaby-fec.notion.site/2026-02-20-30d3afd0fa6e806b8266d4d0ab24aff5?pvs=74',
                            );
                            if (!await launchUrl(url)) {
                              debugPrint("Could not launch $url");
                            }
                          },
                          child: Text(
                            "개인정보처리방침",
                            style: AppTextStyles.bodySecondary12w500.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                      ],
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
