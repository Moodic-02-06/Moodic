import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/core/utils/dialog_util.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/provider/blocked_ids_provider.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/presentation/widgets/report_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommentListItem extends ConsumerWidget {
  final Comment comment;
  final String postId;

  const CommentListItem({
    super.key,
    required this.comment,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider).value;
    final isMyComment = currentUser?.uid == comment.userId;

    // 답글 여부 확인
    final isReply = comment.parentId != null;
    // 탈퇴한 사용자 여부 확인
    final isDeletedUser = comment.userNickname == '탈퇴된 사용자';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMyComment)
                    ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: AppColors.stateError,
                      ),
                      title: const Text(
                        '댓글 삭제',
                        style: TextStyle(color: AppColors.stateError),
                      ),
                      onTap: () {
                        Navigator.pop(context); // 닫기

                        DialogUtil.showDeleteDialog(
                          context,
                          title: '댓글 삭제',
                          content: '정말 삭제하시겠습니까?',
                          onConfirm: () {
                            ref
                                .read(detailViewModelProvider(postId).notifier)
                                .deleteComment(comment.commentId);
                          },
                        );
                      },
                    )
                  else ...[
                    ListTile(
                      leading: const Icon(
                        Icons.block,
                        color: AppColors.gray500,
                      ),
                      title: const Text(
                        '차단하기',
                        style: TextStyle(color: AppColors.gray900),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        DialogUtil.showBlockDialog(
                          context,
                          targetName: '이 댓글을',
                          onConfirm: () async {
                            if (currentUser != null) {
                              await ref
                                  .read(blockTargetUseCaseProvider)
                                  .execute(
                                    currentUser.uid,
                                    comment.commentId,
                                    'comment',
                                  );
                              ref
                                  .read(blockedIdsProvider.notifier)
                                  .addBlockedId(comment.commentId);
                              ref
                                  .read(
                                    detailViewModelProvider(postId).notifier,
                                  )
                                  .removeComment(comment.commentId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('댓글이 차단되었습니다.')),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.report,
                        color: AppColors.stateError,
                      ),
                      title: const Text(
                        '신고하기',
                        style: TextStyle(color: AppColors.stateError),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        final reason = await ReportDialog.show(context);
                        if (reason != null && currentUser != null) {
                          await ref
                              .read(reportTargetUseCaseProvider)
                              .execute(
                                targetId: comment.commentId,
                                targetType: 'comment',
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
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
      // 답글이면 왼쪽 패딩 추가
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
          left: isReply ? 40.0 : 0.0, // 답글 들여쓰기
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 답글 표시 아이콘 (선택 사항 - 디자인에 따라 제거 가능)
            if (isReply)
              const Padding(
                padding: EdgeInsets.only(right: 8.0, top: 4.0),
                child: Icon(
                  Icons.subdirectory_arrow_right,
                  size: 16,
                  color: AppColors.gray500,
                ),
              ),

            GestureDetector(
              onTap: () {
                if (isDeletedUser) return;
                context.pushNamed(
                  AppRoutes.UserPage.name,
                  pathParameters: {'userId': comment.userId},
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.gray300,
                backgroundImage: comment.userImageUrl.isNotEmpty
                    ? NetworkImage(comment.userImageUrl)
                    : null,
                child: comment.userImageUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: AppColors.gray100,
                        size: 24,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isDeletedUser) return;
                          context.pushNamed(
                            AppRoutes.UserPage.name,
                            pathParameters: {'userId': comment.userId},
                          );
                        },
                        child: Text(
                          comment.userNickname,
                          style: AppTextStyles.labelStatus12w500.copyWith(
                            color: isDeletedUser
                                ? AppColors.gray500
                                : AppColors.gray900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatRelativeTime(comment.createdAt),
                        style: AppTextStyles.labelStatus12w500.copyWith(
                          color: AppColors.text600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: isDeletedUser ? AppColors.gray500 : Colors.white,
                      fontSize: 13,
                      fontStyle: isDeletedUser
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 답글 달기 버튼 (탈퇴한 사용자가 아니고, 로그인 상태일 때)
                  if (!isDeletedUser && currentUser != null)
                    GestureDetector(
                      onTap: () {
                        // 답글 달기 모드 설정
                        ref
                            .read(detailViewModelProvider(postId).notifier)
                            .setReplyingTo(comment);
                      },
                      child: Text(
                        '답글 달기',
                        style: AppTextStyles.labelStatus12w500.copyWith(
                          color: AppColors.gray500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
