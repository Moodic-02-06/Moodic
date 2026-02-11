import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/home_page/player_view_model.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_moodic/presentation/widgets/music_display_card.dart';
import 'package:flutter_moodic/presentation/widgets/post_options_bottom_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeFeedCard extends ConsumerWidget {
  final Post post;

  const HomeFeedCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  CircleAvatar(
                    backgroundColor: AppColors.gray300,

                    backgroundImage: post.userImageUrl.isNotEmpty
                        ? NetworkImage(post.userImageUrl)
                        : null,

                    child: post.userImageUrl.isEmpty
                        ? Icon(Icons.person, color: AppColors.gray100, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userNickname,
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
              GestureDetector(
                onTap: () {
                  // 1. 현재 유저 정보 가져오기 (ref 사용)
                  final currentUser = ref.read(userProvider).value;
                  final bool isMyPost = currentUser?.uid == post.userId;

                  showModalBottomSheet(
                    context: context,
                    backgroundColor:
                        Colors.transparent, // 배경 투명하게 (그래야 위젯 곡선이 보임)
                    isScrollControlled: true,
                    builder: (context) {
                      return PostOptionsBottomSheet(
                        isMyPost: isMyPost,
                        onEdit: () {
                          Navigator.pop(context);
                          // TODO: 수정 페이지로 이동 로직 (post 데이터 전달)
                        },
                        onDelete: () {
                          Navigator.pop(context);
                          // TODO: 삭제 확인 다이얼로그 띄우기 및 삭제 로직
                        },
                        onReport: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('신고가 접수되었습니다.')),
                          );
                        },
                      );
                    },
                  );
                },
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ),
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
              MoodBadge(moodLabel: post.mood),
              const SizedBox(height: 12),
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
              _FeedItem(
                icon: post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                count: post.likeCount.toString(),
              ),
              const SizedBox(width: 25),
              _FeedItem(
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

class _FeedItem extends StatelessWidget {
  final IconData icon;
  final String count;

  const _FeedItem({required this.icon, required this.count});

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
