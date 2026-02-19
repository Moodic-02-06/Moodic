import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
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

/// Post 객체 대신 postId만 받아서 ViewModel이 Firestore에서 직접 로드합니다.
class DetailPage extends ConsumerStatefulWidget {
  final String postId;

  const DetailPage({super.key, required this.postId});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    final content = _commentController.text.trim();
    final currentUser = ref.read(userProvider).value;

    if (content.isEmpty) return;

    if (currentUser == null) {
      debugPrint('--- [UI] 유저 정보가 없어서 중단됨');
      return;
    }

    ref
        .read(detailViewModelProvider(widget.postId).notifier)
        .addComment(content, currentUser);

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
    final detailState = ref.watch(detailViewModelProvider(widget.postId));

    if (detailState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (detailState.error != null) {
      return Scaffold(body: Center(child: Text('에러 발생: ${detailState.error}')));
    }

    // post는 ViewModel이 Firestore에서 로드한 데이터만 사용
    final post = detailState.post;
    if (post == null) {
      return const Scaffold(body: Center(child: Text('게시글을 불러올 수 없습니다.')));
    }
    final comments = detailState.comments;

    return Scaffold(
      backgroundColor: AppColors.primary700,
      bottomSheet: CommentInputField(
        controller: _commentController,
        onSubmit: _submitComment,
        postId: widget.postId,
      ),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(detailViewModelProvider(widget.postId));
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
                      final parentComments = comments
                          .where((c) => c.parentId == null)
                          .toList();

                      parentComments.sort(
                        (a, b) => a.createdAt.compareTo(b.createdAt),
                      );

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: parentComments.length,
                        itemBuilder: (context, index) {
                          final parent = parentComments[index];
                          final replies = comments
                              .where((c) => c.parentId == parent.commentId)
                              .toList();

                          replies.sort(
                            (a, b) => a.createdAt.compareTo(b.createdAt),
                          );

                          return CommentThreadItem(
                            parentComment: parent,
                            replies: replies,
                            postId: widget.postId,
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
