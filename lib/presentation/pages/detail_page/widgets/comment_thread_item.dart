import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/widgets/comment_list_item.dart';

class CommentThreadItem extends StatefulWidget {
  final Comment parentComment;
  final List<Comment> replies;
  final String postId;

  const CommentThreadItem({
    super.key,
    required this.parentComment,
    required this.replies,
    required this.postId,
  });

  @override
  State<CommentThreadItem> createState() => _CommentThreadItemState();
}

class _CommentThreadItemState extends State<CommentThreadItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasReplies = widget.replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 부모 댓글
        CommentListItem(comment: widget.parentComment, postId: widget.postId),

        // 답글이 있는 경우, 답글 보기/숨기기 버튼 및 답글 목록
        if (hasReplies) ...[
          // 답글 보기/숨기기 버튼 (왼쪽 들여쓰기 적용)
          Padding(
            padding: const EdgeInsets.only(left: 48.0, bottom: 8.0, top: 4.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 24, height: 1, color: AppColors.gray500),
                  const SizedBox(width: 8),
                  Text(
                    _isExpanded ? '답글 숨기기' : '답글 ${widget.replies.length}개 보기',
                    style: AppTextStyles.labelStatus12w500.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 확장된 경우 답글 목록 표시
          if (_isExpanded)
            Column(
              children: widget.replies.map((reply) {
                return CommentListItem(comment: reply, postId: widget.postId);
              }).toList(),
            ),
        ],
      ],
    );
  }
}
