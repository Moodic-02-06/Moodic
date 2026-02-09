import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

//////////////////////////////////////////////////
/// 1️⃣ 기분 선택 섹션
//////////////////////////////////////////////////

class MoodSelectorSection extends StatelessWidget {
  const MoodSelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final moods = [
      ('☺️', '행복', true),
      ('😢', '우울', false),
      ('😡', '분노', false),
      ('😐', '평온', false),
      ('😴', '피곤', false),
      ('😍', '설렘', false),
      ('🤯', '스트레스', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 기분은 어때요?',
          style: AppTextStyles.bodyPrimary16w500.copyWith(
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.map((mood) {
            return MoodItem(
              emoji: mood.$1,
              label: mood.$2,
              isSelected: mood.$3,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MoodItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;

  const MoodItem({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.statusWarning : AppColors.gray100;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(38),
            border: Border.all(color: AppColors.primary600),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: AppTextStyles.labelStatus12w500.copyWith(
            color: isSelected ? AppColors.statusWarning : AppColors.gray400,
          ),
        ),
      ],
    );
  }
}
