import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/dialog_util.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page_view_model.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/provider/blocked_ids_provider.dart';
import 'package:flutter_moodic/presentation/widgets/post_options_bottom_sheet.dart';
import 'package:flutter_moodic/presentation/widgets/report_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserHeader extends ConsumerWidget {
  final Post post;
  final String time;

  const UserHeader({super.key, required this.post, required this.time});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
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
                    ? const Icon(
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
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    time,
                    style: AppTextStyles.labelStatus12w500.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
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
                    Navigator.pop(context);
                    ref.read(writeViewModelProvider.notifier).initEdit(post);

                    context.push('/write', extra: post);
                  },
                  onDelete: () {
                    final postId = post.postId;

                    DialogUtil.showDeleteDialog(
                      context,
                      onConfirm: () async {
                        await ref
                            .read(detailViewModelProvider(postId).notifier)
                            .deletePost(postId);

                        // Sheet
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }

                        // Route
                        if (context.mounted) {
                          context.pop();
                        }
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
                              .execute(currentUser.uid, post.postId, 'post');
                          ref
                              .read(blockedIdsProvider.notifier)
                              .addBlockedId(post.postId);
                          // 상세 페이지에서 차단 시 메인으로 돌아갑니다.
                          if (context.mounted) {
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('게시글이 차단되었습니다.')),
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
            decoration: const BoxDecoration(color: Colors.transparent),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.more_vert, size: 20, color: AppColors.gray500),
            ),
          ),
        ),
      ],
    );
  }
}
