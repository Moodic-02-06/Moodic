import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/emotion_graph.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/grid_view.dart';
import 'package:flutter_moodic/presentation/pages/my_page_edit/my_page_edit.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "프로필",
          style: AppTextStyles.titlePrimary20w600.copyWith(
            color: AppColors.text900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPageEdit()),
              );
            },
            icon: Icon(Icons.edit, color: AppColors.gray500),
          ),
          //
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // 프로필 이미지 받아와서 넣어주는곳
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(width: 90, height: 90, color: Colors.grey),
                ),
                SizedBox(width: 12),
                // 닉네임,소개
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Maenggo",
                      style: AppTextStyles.titlePrimary20w600.copyWith(
                        color: AppColors.text900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "반갑습니다",
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: AppColors.text900,
                      ),
                    ),
                    //
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Text(
                "이달의 감정 리포트",
                style: AppTextStyles.titleSecondary18w500.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
            //감정 그래프
            EmotionGraph(),
            SizedBox(height: 12),
            MyPageGridView(),
          ],
        ),
      ),
    );
  }
}
