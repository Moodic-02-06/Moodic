import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/core/utils/dialog_util.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page_view_model.dart';
import 'package:flutter_moodic/presentation/provider/global_music_player_provider.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/provider/blocked_ids_provider.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_moodic/presentation/widgets/music_display_card.dart';
import 'package:flutter_moodic/core/service/analytics_service.dart';
import 'package:flutter_moodic/presentation/widgets/post_options_bottom_sheet.dart';
import 'package:flutter_moodic/presentation/widgets/report_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              GestureDetector(
                onTap: () {
                  context.push('/user/${post.userId}');
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.gray300,
                      backgroundImage: post.userImageUrl.isNotEmpty
                          ? NetworkImage(post.userImageUrl)
                          : null,
                      child: post.userImageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: AppColors.gray100,
                              size: 24,
                            )
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
              ),
              GestureDetector(
                onTap: () {
                  //  현재 유저 정보 가져오기 (ref 사용)
                  final currentUser = ref.read(userProvider).value;
                  final bool isMyPost = currentUser?.uid == post.userId;

                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) {
                      return PostOptionsBottomSheet(
                        isMyPost: isMyPost,
                        onEdit: () {
                          ref
                              .read(writeViewModelProvider.notifier)
                              .initEdit(post);

                          context.push('/write', extra: post);
                        },
                        onDelete: () {
                          Navigator.pop(context);
                          DialogUtil.showDeleteDialog(
                            context,
                            onConfirm: () {
                              ref
                                  .read(homeViewModelProvider.notifier)
                                  .deletePost(post.postId);
                            },
                          );
                        },
                        onBlock: () {
                          Navigator.pop(context);
                          DialogUtil.showBlockDialog(
                            context,
                            targetName: '이 게시글을',
                            onConfirm: () async {
                              if (currentUser != null) {
                                await ref
                                    .read(blockTargetUseCaseProvider)
                                    .execute(
                                      currentUser.uid,
                                      post.postId,
                                      'post',
                                    );
                                ref
                                    .read(blockedIdsProvider.notifier)
                                    .addBlockedId(post.postId);
                                ref
                                    .read(homeViewModelProvider.notifier)
                                    .removePost(post.postId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('게시글이 차단되었습니다.'),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                        onReport: () async {
                          Navigator.pop(context);
                          final reason = await ReportDialog.show(context);
                          if (reason != null && currentUser != null) {
                            await ref
                                .read(reportTargetUseCaseProvider)
                                .execute(
                                  targetId: post.postId,
                                  targetType: 'post',
                                  reporterId: currentUser.uid,
                                  reason: reason,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('신고가 접수되었습니다.')),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.more_vert,
                      size: 20,
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
              final globalState = ref.watch(globalMusicPlayerProvider);
              final isCurrentPlaying =
                  globalState.playingId == post.postId && globalState.isPlaying;

              return MusicDisplayCard(
                music: post.music,
                isPlaying: isCurrentPlaying,
                // previewUrl 없으면 재생 버튼 비활성화 (null → 버튼 미표시)
                onPlayPressed: post.music.previewUrl.isNotEmpty
                    ? () {
                        // 재생할 때만 로그 수집 (정지할 때는 제외)
                        if (!isCurrentPlaying) {
                          ref
                              .read(analyticsServiceProvider)
                              .logPlayPreview(musicTitle: post.music.title);
                        }
                        ref
                            .read(globalMusicPlayerProvider.notifier)
                            .togglePlay(post.postId, post.music.previewUrl);
                      }
                    : null,
                backgroundColor: AppColors.primary900,
              );
            },
          ),

          const SizedBox(height: 12),

          // ================= 메인 이미지 =================
          if (post.imageUrls.isNotEmpty) //  이미지가 있을 때만 렌더링하도록 처리
            Column(
              children: [
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
              ],
            ),

          // ================= 감정 + 텍스트 =================
          MoodBadge(moodLabel: post.mood),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: AppTextStyles.bodySecondary14w500.copyWith(
              color: AppColors.text900,
            ),
            maxLines: 7,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // ================= 좋아요 / 댓글 =================
          Row(
            children: [
              _FeedItem(
                // post.isLikedByMe 값에 따라 아이콘 형상을 결정
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
