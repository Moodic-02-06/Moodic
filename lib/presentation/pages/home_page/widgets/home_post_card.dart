import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/post.dart';

class HomeFeedCard extends StatelessWidget {
  final Post post;
  final void Function(String postId) onLikeToggle;

  const HomeFeedCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                        post.userId,
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.text900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${post.createdAt.hour}시간 전',
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.network(
                        post.music.artwork.isNotEmpty
                            ? post.music.artwork
                            : 'https://picsum.photos/200/300',
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.music.title,
                          style: AppTextStyles.bodyPrimary16w600.copyWith(
                            color: AppColors.text900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.music.artist,
                          style: AppTextStyles.labelStatus12w500.copyWith(
                            color: AppColors.text600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.gray500,
                  size: 28,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================= 메인 이미지 =================
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/200/300',
              width: double.infinity,
              height: 200,
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
                  color: AppColors.statusWarning.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: AppColors.statusWarning),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('😊'),
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
                icon: post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                count: post.likeCount.toString(),
                onTap: () => onLikeToggle(post.postId),
              ),
              const SizedBox(width: 25),
              _ActionItem(
                icon: Icons.chat_bubble_outline,
                count: post.commentCount.toString(),
                onTap: () {}, // 댓글 버튼 클릭
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
  final VoidCallback? onTap;

  const _ActionItem({required this.icon, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
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
      ),
    );
  }
}
