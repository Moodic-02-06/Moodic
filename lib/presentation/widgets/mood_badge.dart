import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';

class MoodBadge extends StatelessWidget {
  final String moodLabel;
  final bool useDarkBackground;

  const MoodBadge({
    super.key,
    required this.moodLabel,
    this.useDarkBackground = false,
  });

  static const double _borderRadius = 23.0;

  @override
  Widget build(BuildContext context) {
    // Label 문자열을 기반으로 MoodType 찾기 (없으면 기본값 happy)
    final moodData = MoodType.fromLabel(moodLabel);

    Widget badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: moodData.color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: moodData.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(moodData.emoji),
          const SizedBox(width: 6),
          Text(
            moodData.label,
            style: AppTextStyles.bodySecondary14w500.copyWith(
              color: AppColors.text900,
            ),
          ),
        ],
      ),
    );

    if (useDarkBackground) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primary900,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: badgeContent,
      );
    }

    return badgeContent;
  }
}
