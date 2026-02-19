import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';

class AnimatedSortToggle extends StatelessWidget {
  final FeedSortType sortType;
  final Function(FeedSortType) onTap;

  const AnimatedSortToggle({
    super.key,
    required this.sortType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double height = 48;
    // 최신순(좌측) = -1.0, 인기순(우측) = 1.0
    final alignX = sortType == FeedSortType.latest ? -1.0 : 1.0;

    return Container(
      height: height + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary600,
        borderRadius: BorderRadius.circular(61),
      ),
      child: Stack(
        children: [
          // 움직이는 배경 (Thumb)
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment(alignX, 0),
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary900,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 2. 텍스트 버튼들 (Overlay)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(FeedSortType.latest),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: sortType == FeedSortType.latest
                            ? AppColors.text900
                            : AppColors.gray500,
                      ),
                      child: const Text('최신 글'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(FeedSortType.mostLiked),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: sortType == FeedSortType.mostLiked
                            ? AppColors.text900
                            : AppColors.gray500,
                      ),
                      child: const Text('인기 글'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
