import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_feed_card.dart';
import 'package:flutter_moodic/presentation/pages/like_page/like_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LikePage extends ConsumerWidget {
  const LikePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeFeedsState = ref.watch(likeFeedsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "좋아요",
          style: AppTextStyles.titlePrimary20w600.copyWith(
            color: AppColors.text900,
          ),
        ),
      ),
      body: likeFeedsState.when(
        data: (feeds) {
          if (feeds.isEmpty) {
            return const Center(
              child: Text(
                "좋아요 누른 게시글이 없습니다",
                style: TextStyle(color: AppColors.gray500),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12).copyWith(bottom: 120),
            itemCount: feeds.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = feeds[index];
              return GestureDetector(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.DetailPage.name,
                    pathParameters: {'id': post.postId},
                    extra: post,
                  );
                },
                child: HomeFeedCard(post: post),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: Text(
            "데이터를 불러오는 중 오류가 발생했습니다.\n$error",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.stateError),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
