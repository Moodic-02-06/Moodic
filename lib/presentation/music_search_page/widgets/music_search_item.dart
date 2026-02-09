import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/music.dart';

//////////////////////////////////////////////////
/// 검색 결과 아이템
//////////////////////////////////////////////////

class MusicSearchItem extends StatelessWidget {
  final Music music;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final VoidCallback onSelect;

  const MusicSearchItem({
    super.key,
    required this.music,
    required this.isPlaying,
    required this.onPlayPressed,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying
              ? AppColors.secondary500.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.secondary500.withValues(alpha: 0.1),
          highlightColor: AppColors.secondary500.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Album Art
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: music.artwork.isNotEmpty
                          ? Image.network(
                              music.artwork,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: AppColors.primary600,
                              child: const Icon(
                                Icons.music_note_rounded,
                                color: AppColors.gray500,
                              ),
                            ),
                    ),
                    if (isPlaying)
                      Container(
                        width: 60,
                        height: 60,
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
                const SizedBox(width: 16),

                // Title & Artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        music.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: isPlaying
                              ? AppColors.secondary500
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        music.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySecondary14w500.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onPlayPressed,
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
                    IconButton(
                      onPressed: onSelect,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gray100,
                        padding: const EdgeInsets.all(8),
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.gray400,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
