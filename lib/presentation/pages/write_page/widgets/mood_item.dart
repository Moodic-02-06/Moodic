import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

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
            color: isSelected ? AppColors.statusWarning : AppColors.gray300,
          ),
        ),
      ],
    );
  }
}
