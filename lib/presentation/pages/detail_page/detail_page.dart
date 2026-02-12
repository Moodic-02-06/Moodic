import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/date_formatter.dart';
import 'package:flutter_moodic/core/utils/music_link_utils.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/home_page/player_view_model.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final Post post;

  const DetailPage({super.key, required this.post});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
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
                widget.post.userNickname,
                DateFormatter.formatRelativeTime(widget.post.createdAt),
              ),
              SizedBox(height: 16),
              _buildMusicCard(),
              SizedBox(height: 24),

              if (widget.post.imageUrls.isNotEmpty)
                Column(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,

                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;

                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
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
                ),
              MoodBadge(moodLabel: widget.post.mood),
              SizedBox(height: 12),
              Text(
                widget.post.content,
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: 12),
              _buildInteractionBar(
                widget.post.likeCount,
                widget.post.commentCount,
              ),
              const Divider(color: Color(0xFF1E293B), height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 120.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 30, // 댓글 개수만큼 반복
                  itemBuilder: (context, index) {
                    return _buildCommentItem('현더', 'ㅋㅋㅋ', '1분전');
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
  Widget _buildUserHeader(String name, String time) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.gray300,

          backgroundImage: widget.post.userImageUrl.isNotEmpty
              ? NetworkImage(widget.post.userImageUrl)
              : null,

          child: widget.post.userImageUrl.isEmpty
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
        Icon(Icons.more_vert, color: AppColors.gray500),
      ],
    );
  }

  Widget _buildMusicCard() {
    return Row(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage: NetworkImage(widget.post.music.artwork),
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
                          style: AppTextStyles.bodySecondary14w500.copyWith(
                            color: AppColors.text600,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8),

                  Consumer(
                    builder: (context, ref, child) {
                      final playerState = ref.watch(playerViewModelProvider);
                      final isCurrentPlaying =
                          playerState.playingPostId == widget.post.postId &&
                          playerState.isPlaying;

                      return IconButton(
                        onPressed: () {
                          ref
                              .read(playerViewModelProvider.notifier)
                              .togglePlay(
                                widget.post.postId,
                                widget.post.music.previewUrl,
                              );
                        },
                        icon: Icon(
                          isCurrentPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_arrow,
                        ),
                        iconSize: 32,
                        color: isCurrentPlaying
                            ? AppColors.primary500
                            : AppColors.gray500,
                      );
                    },
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
  Widget _buildCommentItem(String name, String content, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://picsum.photos/84'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelStatus12w500.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: AppTextStyles.labelStatus12w500.copyWith(
                        color: AppColors.text600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
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
      color: const Color(0xFF0A0A14),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '따뜻한 한마디를 남겨주세요',
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          filled: true,
          fillColor: const Color(0xFF1E1E30),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Icon(Icons.send, color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}
