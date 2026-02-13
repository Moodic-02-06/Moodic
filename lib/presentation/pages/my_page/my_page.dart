import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/grid_view.dart';
import 'package:flutter_moodic/presentation/pages/my_page_edit/my_page_edit.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    final user = userState.value;
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
                      '${user?.nickname}',
                      style: AppTextStyles.titlePrimary20w600.copyWith(
                        color: AppColors.text900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${user?.bio}",
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
            MyPageGridView(),
          ],
        ),
      ),
    );
  }
}
