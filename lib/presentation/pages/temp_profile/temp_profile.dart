import 'package:flutter/material.dart';
import 'package:flutter_moodic/presentation/widgets/primary_bottom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

class TempProfile extends StatefulWidget {
  const TempProfile({super.key});

  @override
  State<TempProfile> createState() => _TempProfileState();
}

class _TempProfileState extends State<TempProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("임시 프로필")),

      // TODO: 경로 수정하기
      bottomNavigationBar: PrimaryBottomButton(
        label: '완료하기',
        isLoading: false,
        onPressed: () {
          context.go('/?tempPass=true');
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  children: [
                    // 랜덤 이미지 들어감
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),
              Text("닉네임", style: TextStyle(color: Colors.white)),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '홍길동',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyPrimary16w600.copyWith(
                    color: AppColors.text900,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                "2~12자의 한글, 영문, 숫자만 사용가능 합니다",
                style: AppTextStyles.labelStatus12w500.copyWith(
                  color: AppColors.text900,
                ),
              ),
              SizedBox(height: 12),
              Container(width: double.infinity, height: 1, color: Colors.grey),
              Spacer(),
              Text(
                "간단하게 입력 후\n프로필에서 수정 가능합니다.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              SizedBox(width: double.infinity, height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
