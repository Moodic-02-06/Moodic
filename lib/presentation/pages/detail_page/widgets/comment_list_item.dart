import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/core/utils/dialog_util.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        if (!isMyComment) return;

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('댓글 삭제'),
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
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.gray300,
              backgroundImage: comment.userImageUrl.isNotEmpty
                  ? NetworkImage(comment.userImageUrl)
                  : null,
              child: comment.userImageUrl.isEmpty
                  ? const Icon(Icons.person, color: AppColors.gray100, size: 24)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.userNickname,
                        style: AppTextStyles.labelStatus12w500.copyWith(
                          color: AppColors.gray900,
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
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
