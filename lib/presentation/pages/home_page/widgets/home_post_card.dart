import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/home_page/player_view_model.dart';
import 'package:flutter_moodic/presentation/widgets/music_display_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeFeedCard extends ConsumerWidget {
  final Post post;
  final void Function(String postId) onLikeToggle;

  const HomeFeedCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodData = MoodType.values.firstWhere(
      (m) => m.label == post.mood || m.name == post.mood,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= 작성자 영역 =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.network(
                      'https://picsum.photos/36',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.text900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatRelativeTime(post.createdAt),
                        style: AppTextStyles.labelStatus12w500.copyWith(
                          color: AppColors.text600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.more_vert, size: 18, color: AppColors.gray500),
            ],
          ),

          const SizedBox(height: 12),

          // ================= 콘텐츠 카드 =================
          Consumer(
            builder: (context, ref, child) {
              final playerState = ref.watch(playerViewModelProvider);
              final isCurrentPlaying =
                  playerState.playingPostId == post.postId &&
                  playerState.isPlaying;

              return MusicDisplayCard(
                music: post.music,
                isPlaying: isCurrentPlaying,
                onPlayPressed: () {
                  ref
                      .read(playerViewModelProvider.notifier)
                      .togglePlay(post.postId, post.music.previewUrl);
                },
                backgroundColor: AppColors.primary900,
              );
            },
          ),

          const SizedBox(height: 12),

          // ================= 메인 이미지 =================
          if (post.imageUrls.isNotEmpty) //  이미지가 있을 때만 렌더링하도록 처리
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrls.first,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 12),

          // ================= 감정 + 텍스트 =================
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: moodData.color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: moodData.color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(moodData.emoji),
                    const SizedBox(width: 6),
                    Text(
                      post.mood,
                      style: AppTextStyles.bodySecondary14w500.copyWith(
                        color: AppColors.text900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                post.content,
                style: AppTextStyles.bodySecondary14w500.copyWith(
                  color: AppColors.text900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ================= 좋아요 / 댓글 =================
          Row(
            children: [
              _ActionItem(
                icon: !post.isLikedByMe
                    ? Icons.favorite
                    : Icons.favorite_border,
                count: post.likeCount.toString(),
              ),
              const SizedBox(width: 25),
              _ActionItem(
                icon: Icons.chat_bubble_outline,
                count: post.commentCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String count;

  const _ActionItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gray500),
        const SizedBox(width: 4),
        Text(
          count,
          style: AppTextStyles.labelStatus12w500.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
