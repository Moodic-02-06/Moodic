import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/music.dart';

class MusicDisplayCard extends StatelessWidget {
  final Music music;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final VoidCallback? onSelect; // 선택 사항으로 변경
  final bool showAddButton; // 추가 버튼 노출 여부
  final Color? backgroundColor;

  const MusicDisplayCard({
    super.key,
    required this.music,
    required this.isPlaying,
    required this.onPlayPressed,
    this.onSelect,
    this.showAddButton = false, // 기본값은 버튼 안 보임
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
        borderRadius: BorderRadius.circular(16), // 위 컨테이너와 일치
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
              ? Image.network(
                  music.artwork,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
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
        // 재생 버튼 (항상 노출)
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
        // 추가 버튼 (조건부 노출)
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
      ],
    );
  }
}
