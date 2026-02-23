import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/music.dart';

class MusicDisplayCard extends StatelessWidget {
  final Music music;
  final bool isPlaying;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onSelect;
  final bool showAddButton;
  final bool showDeleteButton;
  final VoidCallback? onDelete;
  final Color? backgroundColor;

  const MusicDisplayCard({
    super.key,
    required this.music,
    required this.isPlaying,
    this.onPlayPressed,
    this.onSelect,
    this.showAddButton = false,
    this.showDeleteButton = false,
    this.onDelete,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary700,
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildAlbumArt(),
                const SizedBox(width: 16),
                _buildInfo(),
                const SizedBox(width: 8),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: music.artwork.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: music.artwork,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.primary600,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary500,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.primary600,
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.stateError,
                    ),
                  ),
                )
              : Container(
                  width: 64,
                  height: 64,
                  color: AppColors.primary600,
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: AppColors.gray500,
                  ),
                ),
        ),
        if (isPlaying)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.equalizer, color: AppColors.secondary500),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            music.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyPrimary16w600.copyWith(
              color: isPlaying ? AppColors.secondary500 : Colors.white,
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
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onPlayPressed != null)
          IconButton(
            onPressed: onPlayPressed,
            style: IconButton.styleFrom(
              backgroundColor: isPlaying
                  ? AppColors.secondary500
                  : AppColors.gray100,
              padding: const EdgeInsets.all(8),
            ),
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isPlaying ? AppColors.primary900 : AppColors.gray400,
              size: 20,
            ),
          ),

        if (showAddButton) ...[
          const SizedBox(width: 8),
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

        if (showDeleteButton) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gray100,
              padding: const EdgeInsets.all(8),
            ),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.gray400,
              size: 24,
            ),
          ),
        ],
      ],
    );
  }
}
