import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/core/utils/music_link_utils.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/provider/global_music_player_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends ConsumerStatefulWidget {
  final Post post;

  const DetailPage({super.key, required this.post});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  int _currentPage = 0;
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
      bottomSheet: _buildCommentInputField(),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(
                name: post.userNickname,
                time: DateFormatter.formatRelativeTime(post.createdAt),
                imageUrl: post.userImageUrl,
              ),
              SizedBox(height: 16),
              _buildMusicCard(),
              SizedBox(height: 24),

              if (post.imageUrls.isNotEmpty) _imageCarousel(),
              MoodBadge(moodLabel: post.mood),
              SizedBox(height: 12),
              Text(
                post.content,
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: 12),
              _buildInteractionBar(post.likeCount, post.commentCount),
              const Divider(color: AppColors.gray100, height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 120.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentItem(comments[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 사용자 헤더
  Widget _buildUserHeader({
    required String imageUrl,
    required String name,
    required String time,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.gray300,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? Icon(Icons.person, color: AppColors.gray100, size: 24)
              : null,
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
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
        Spacer(),
        Icon(Icons.more_vert, size: 20, color: AppColors.gray500),
      ],
    );
  }

  // 음악 카드
  Widget _buildMusicCard() {
    return Consumer(
      builder: (context, ref, child) {
        final playerState = ref.watch(globalMusicPlayerProvider);
        final isPlaying =
            playerState.playingId == widget.post.postId &&
            playerState.isPlaying;
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? AppColors.secondary500.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: widget.post.music.artwork.isNotEmpty
                        ? Image.network(
                            widget.post.music.artwork,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 84,
                            height: 84,
                            color: AppColors.primary600,
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: AppColors.gray500,
                            ),
                          ),
                  ),
                  if (isPlaying)
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.equalizer,
                        color: AppColors.secondary500,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.music.title,
                                maxLines: 1,
                                style: AppTextStyles.bodyPrimary16w600.copyWith(
                                  color: AppColors.gray900,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                widget.post.music.artist,
                                maxLines: 1,
                                style: AppTextStyles.bodySecondary14w500
                                    .copyWith(
                                      color: AppColors.text600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 8),

                        IconButton(
                          onPressed: () {
                            ref
                                .read(globalMusicPlayerProvider.notifier)
                                .togglePlay(
                                  widget.post.postId,
                                  widget.post.music.previewUrl,
                                );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: isPlaying
                                ? AppColors.secondary500
                                : AppColors.gray100,
                            padding: const EdgeInsets.all(8),
                          ),
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: isPlaying
                                ? AppColors.primary900
                                : AppColors.gray400,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _buildMusicTag(
                          label: 'Spotify',
                          url: buildSpotifySearchUrl(
                            widget.post.music.artist,
                            widget.post.music.title,
                          ),
                        ),

                        const SizedBox(width: 8),

                        _buildMusicTag(
                          label: 'YouTube',
                          url: buildYoutubeMusicSearchUrl(
                            widget.post.music.artist,
                            widget.post.music.title,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 음악 버튼
  Widget _buildMusicTag({
    required String label,
    required String url,
    String? fallbackUrl,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final Uri uri = Uri.parse(url);

          // 1 앱 딥링크 먼저 시도
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            return;
          }

          // 2 실패하면 웹 링크로 fallback
          if (fallbackUrl != null) {
            final webUri = Uri.parse(fallbackUrl);

            if (await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
              return;
            }
          }

          // 3 전부 실패
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('음악 앱을 열 수 없습니다.')));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gray300.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: AppTextStyles.bodyPrimary16w600.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              const Spacer(),
              Transform.rotate(
                angle: math.pi / 2,
                child: const Icon(
                  Icons.vertical_align_top,
                  color: AppColors.gray500,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 이미지 캐러셀
  Widget _imageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: widget.post.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.post.imageUrls[index];
              if (url.isEmpty) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,

                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return const Center(child: CircularProgressIndicator());
                    },

                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.gray300,
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.post.imageUrls.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index
                    ? AppColors.gray300
                    : AppColors.primary600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 좋아요, 댓글 아이콘
  Widget _buildInteractionBar(int likes, int comments) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            print("좋아요 클릭됨");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, color: AppColors.gray500, size: 28),
                const SizedBox(width: 6),
                Text(
                  '$likes',
                  style: AppTextStyles.bodyPrimary16w600.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppColors.gray500,
                size: 28,
              ),
              const SizedBox(width: 6),
              Text(
                '$comments',
                style: AppTextStyles.bodyPrimary16w600.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 댓글 아이템
  Widget _buildCommentItem(Comment comment) {
    return Padding(
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
                ? Icon(Icons.person, color: AppColors.gray100, size: 24)
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
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray100)),
        color: AppColors.primary900,
      ),
      child: TextField(
        controller: _commentController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '따뜻한 한마디를 남겨주세요',
          hintStyle: AppTextStyles.bodySecondary14w500.copyWith(
            color: AppColors.gray500,
          ),
          filled: true,
          fillColor: AppColors.primary600,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: AppColors.gray400),
            onPressed: _submitComment,
          ),
        ),
      ),
    );
  }
}
