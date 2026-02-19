import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/widgets/comment_input_field.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/widgets/comment_thread_item.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/widgets/image_carousel.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/widgets/interaction_bar.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/widgets/music_player_card.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/widgets/user_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailPage extends ConsumerStatefulWidget {
  final Post post;

  const DetailPage({super.key, required this.post});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    final content = _commentController.text.trim();
    final currentUser = ref.read(userProvider).value;

    // 예외 케이스 먼저 쳐내기
    if (content.isEmpty) return;

    if (currentUser == null) {
      debugPrint('--- [UI] 유저 정보가 없어서 중단됨');
      return;
    }

    // 핵심 로직 실행
    ref
        .read(detailViewModelProvider(widget.post.postId).notifier)
        .addComment(content, currentUser);

    // 후속 작업 (UI 정리)
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(detailViewModelProvider(widget.post.postId));

    if (detailState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (detailState.error != null) {
      return Scaffold(body: Center(child: Text('에러 발생: ${detailState.error}')));
    }

    // 데이터가 있을 때 (post가 null이 아닐 때)
    final post = detailState.post ?? widget.post;
    final comments = detailState.comments;

    return Scaffold(
      backgroundColor: AppColors.primary700,
      bottomSheet: CommentInputField(
        controller: _commentController,
        onSubmit: _submitComment,
        postId: widget.post.postId,
      ),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(detailViewModelProvider(widget.post.postId));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserHeader(
                  post: post,
                  time: DateFormatter.formatRelativeTime(post.createdAt),
                ),
                SizedBox(height: 16),
                MusicPlayerCard(post: post),
                SizedBox(height: 24),

                if (post.imageUrls.isNotEmpty)
                  ImageCarousel(imageUrls: post.imageUrls),
                MoodBadge(moodLabel: post.mood),
                SizedBox(height: 12),
                Text(
                  post.content,
                  style: AppTextStyles.bodyPrimary16w500.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: 12),
                InteractionBar(post: post),
                const Divider(color: AppColors.gray100, height: 32),
                Padding(
                  padding: const EdgeInsets.only(bottom: 120.0),
                  child: Builder(
                    builder: (context) {
                      // 댓글 그룹화 로직
                      // 1. 부모 댓글(parentId == null) 필터링
                      final parentComments = comments
                          .where((c) => c.parentId == null)
                          .toList();

                      // 생성일 순 정렬 (오래된 순)
                      parentComments.sort(
                        (a, b) => a.createdAt.compareTo(b.createdAt),
                      );

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: parentComments.length,
                        itemBuilder: (context, index) {
                          final parent = parentComments[index];
                          // 2. 해당 부모의 대댓글 찾기
                          final replies = comments
                              .where((c) => c.parentId == parent.commentId)
                              .toList();

                          // 대댓글도 생성일 순 정렬
                          replies.sort(
                            (a, b) => a.createdAt.compareTo(b.createdAt),
                          );

                          return CommentThreadItem(
                            parentComment: parent,
                            replies: replies,
                            postId: widget.post.postId,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
