import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/music_link_utils.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/provider/global_music_player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_moodic/core/service/analytics_service.dart';

class MusicPlayerCard extends ConsumerWidget {
  final Post post;

  const MusicPlayerCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(globalMusicPlayerProvider);
    final isPlaying =
        playerState.playingId == post.postId && playerState.isPlaying;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary900,
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
                borderRadius: BorderRadius.circular(8),
                child: post.music.artwork.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: post.music.artwork,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 84,
                          height: 84,
                          color: AppColors.primary600,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.secondary500,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 84,
                          height: 84,
                          color: AppColors.primary600,
                          child: const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.stateError,
                          ),
                        ),
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
                            post.music.title,
                            maxLines: 1,
                            style: AppTextStyles.bodyPrimary16w600.copyWith(
                              color: AppColors.gray900,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            post.music.artist,
                            maxLines: 1,
                            style: AppTextStyles.bodySecondary14w500.copyWith(
                              color: AppColors.text600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      onPressed: () {
                        if (!isPlaying) {
                          ref
                              .read(analyticsServiceProvider)
                              .logPlayDetail(
                                musicTitle: post.music.title,
                                postId: post.postId,
                              );
                        }
                        ref
                            .read(globalMusicPlayerProvider.notifier)
                            .togglePlay(post.postId, post.music.previewUrl);
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
                      context,
                      label: 'Spotify',
                      url: buildSpotifySearchUrl(
                        post.music.artist,
                        post.music.title,
                      ),
                      onTagPressed: () {
                        ref
                            .read(analyticsServiceProvider)
                            .logExternalLinkClick(
                              platform: 'Spotify',
                              musicTitle: post.music.title,
                              postId: post.postId,
                            );
                      },
                    ),

                    const SizedBox(width: 8),

                    _buildMusicTag(
                      context,
                      label: 'YouTube',
                      url: buildYoutubeMusicSearchUrl(
                        post.music.artist,
                        post.music.title,
                      ),
                      onTagPressed: () {
                        ref
                            .read(analyticsServiceProvider)
                            .logExternalLinkClick(
                              platform: 'YouTube',
                              musicTitle: post.music.title,
                              postId: post.postId,
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicTag(
    BuildContext context, {
    required String label,
    required String url,
    String? fallbackUrl,
    VoidCallback? onTagPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          onTagPressed?.call();
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
          if (!context.mounted) return;

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
}
