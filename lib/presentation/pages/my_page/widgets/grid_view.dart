import 'package:flutter/material.dart';

import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPageGridView extends ConsumerWidget {
  const MyPageGridView({super.key});

  @override
  Widget build(BuildContext contex, WidgetRef ref) {
    final myPageState = ref.watch(myPageViewModelProvider);
    final myState = myPageState.value;
    if (myState == null) {
      return SizedBox.shrink();
    }

    if (myState.feeds.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "작성된 피드가 없습니다",
            style: AppTextStyles.bodyPrimary16w500.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      // 그리드뷰 높이를 자식만큼 줄여서 높이값을 지정해줌
      shrinkWrap: true,
      // 스크롤이 안되게함 // 전체 스크롤만 가능하게 변경됨
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        crossAxisCount: 3,
      ),
      itemCount: myState.feeds.length,
      itemBuilder: (context, index) {
        final post = myState.feeds[index];
        final String artworkUrl = post.music.artwork;
        final String mood = post.mood;
        return GestureDetector(
          onTap: () {
            context.pushNamed(
              AppRoutes.DetailPage.name,
              pathParameters: {'id': post.postId},
              extra: post,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              image: (artworkUrl.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(artworkUrl),
                      fit: BoxFit.cover,
                    )
                  : null,

              borderRadius: BorderRadius.circular(6),
              color: Colors.grey,
            ),

            child: Stack(
              children: [
                if (artworkUrl.isEmpty) Icon(Icons.abc),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: (mood.isNotEmpty)
                        ? MoodBadge(
                            moodLabel: mood.toString(),
                            useDarkBackground: true,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
