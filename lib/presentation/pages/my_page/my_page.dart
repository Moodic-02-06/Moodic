import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/emotion_graph.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/grid_view.dart';
import 'package:flutter_moodic/presentation/pages/my_page_edit/my_page_edit.dart';

import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPageState = ref.watch(myPageViewModelProvider);

    return myPageState.when(
      data: (data) {
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
                // 프로필 이미지 받아와서 넣어주는곳
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey,
                    child:
                        (user?.profileImage != null &&
                            user!.profileImage!.isNotEmpty)
                        ? Image.network(user.profileImage!, fit: BoxFit.cover)
                        : null,
                  ),
                ),
                SizedBox(width: 12),
                // 닉네임,소개
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                Row(
                  children: [
                    // 프로필 이미지 받아와서 넣어주는곳
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.gray300,
                      backgroundImage:
                          //널인지 아닌지 체크 및 안에 데이터가 있는지 없는지 체크
                          (data.profileimage != null &&
                              data.profileimage!.isNotEmpty)
                          ? NetworkImage(data.profileimage!)
                          : null,
                      child:
                          (data.profileimage != null &&
                              data.profileimage!.isEmpty)
                          ? Icon(
                              Icons.person,
                              color: AppColors.gray100,
                              size: 80,
                            )
                          : null,
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: 200,
                      child: Text(
                        "${user?.bio}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.text900,
                        ),
                      ),
                    SizedBox(width: 12),
                    // 닉네임,소개
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.nickname}',
                          style: AppTextStyles.titlePrimary20w600.copyWith(
                            color: AppColors.text900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${data.bio}",
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
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Text(
                "${DateTime.now().year % 100}.${DateTime.now().month.toString().padLeft(2, '0')} 감정 그래프",
                textAlign: TextAlign.left,
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ),
            SizedBox(height: 12),
            EmotionGraph(),
            SizedBox(height: 12),
            MyPageGridView(),
          ],
        ),
      ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Text("mypage에러${error}");
      },
      loading: () {
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
