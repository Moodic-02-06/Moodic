import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InteractionBar extends ConsumerWidget {
  final Post post;

  const InteractionBar({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // 1. 유저 정보 가져오기
            final currentUser = ref.read(userProvider).value;

            if (currentUser != null) {
              // 2. ViewModel의 toggleLike 호출
              ref
                  .read(detailViewModelProvider(post.postId).notifier)
                  .toggleLike(currentUser);
            } else {
              // 로그인 안 된 경우 안내 (선택 사항)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('로그인이 필요한 서비스입니다.')));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  color: post.isLikedByMe ? Colors.red : AppColors.gray500,
                  size: 28,
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.likeCount}',
                  style: AppTextStyles.bodyPrimary16w600.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.gray500,
                size: 28,
              ),
              const SizedBox(width: 6),
              Text(
                '${post.commentCount}',
                style: AppTextStyles.bodyPrimary16w600.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
