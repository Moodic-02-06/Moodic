import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String postId;

  const CommentInputField({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    // 뷰모델 상태 구독을 위해 ConsumerWidget으로 변환하거나 Consumer사용
    return Consumer(
      builder: (context, ref, child) {
        final viewModel = ref.read(detailViewModelProvider(postId).notifier);
        ref.watch(detailViewModelProvider(postId));
        final replyingTo = viewModel.replyingToComment;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary700,
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (replyingTo != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${replyingTo.userNickname}님에게 답글 작성 중...',
                        style: AppTextStyles.labelStatus12w500.copyWith(
                          color: AppColors.moodPurple,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => viewModel.setReplyingTo(null),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: '댓글을 입력하세요...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: AppTextStyles.bodyPrimary16w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onSubmit,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.moodPurple,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
