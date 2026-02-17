import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/emotion_graph.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/grid_view.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/entity_grid_view.dart';
import 'package:flutter_moodic/presentation/pages/my_page_edit/my_page_edit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPageState = ref.watch(myPageViewModelProvider);

    // 데이터가 있거나 로딩 중이어도 기존 데이터가 있다면 내용을 보여줌 (깜빡임 방지)
    if (myPageState.hasValue) {
      final data = myPageState.value!;
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
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지

              // 닉네임, 소개
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary900,
                    backgroundImage:
                        (data.profileimage != null &&
                            data.profileimage!.isNotEmpty)
                        ? NetworkImage(data.profileimage!)
                        : null,
                    child: data.isUploading
                        ? const CircularProgressIndicator()
                        : (data.profileimage == null ||
                              data.profileimage!.isEmpty)
                        ? Icon(Icons.person, color: AppColors.gray100, size: 80)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.nickname,
                          style: AppTextStyles.titlePrimary20w600.copyWith(
                            color: AppColors.text900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          data.bio ?? '',
                          style: AppTextStyles.bodyPrimary16w600.copyWith(
                            color: AppColors.text900,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "${DateTime.now().year % 100}.${DateTime.now().month.toString().padLeft(2, '0')} 감정 그래프",
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: 12),
              EmotionGraph(),
              SizedBox(height: 12),
              // 디버깅용 로그
              Builder(
                builder: (context) {
                  debugPrint("마이페이지: feeds.length = ${data.feeds.length}");
                  return SizedBox.shrink();
                },
              ),
              (data.feeds.isNotEmpty) ? MyPageGridView() : EntityGridView(),
            ],
          ),
        ),
      );
    }

    return myPageState.when(
      data: (data) => SizedBox(), // 위에서 처리됨
      error: (error, stackTrace) {
        return Center(child: Text("mypage 에러: $error"));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
