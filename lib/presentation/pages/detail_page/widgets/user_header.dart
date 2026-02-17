import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/dialog_util.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page_view_model.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/post_options_bottom_sheet.dart';
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
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.gray300,
          backgroundImage: post.userImageUrl.isNotEmpty
              ? NetworkImage(post.userImageUrl)
              : null,
          child: post.userImageUrl.isEmpty
              ? const Icon(Icons.person, color: AppColors.gray100, size: 24)
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
