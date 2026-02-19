import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//////////////////////////////////////////////////
/// 1️⃣ 기분 선택 섹션
//////////////////////////////////////////////////

class MoodSelectorSection extends ConsumerWidget {
  const MoodSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMood = ref.watch(writeViewModelProvider).mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 기분은 어때요?',
          style: AppTextStyles.bodyPrimary16w500.copyWith(
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 16),

        // 가로 스크롤로 모든 기분을 보여줌
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none, // 그림자나 경계선이 잘리지 않게
          child: Row(
            children: MoodType.values.map((mood) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () =>
                      ref.read(writeViewModelProvider.notifier).setMood(mood),
                  child: MoodItem(mood: mood, isSelected: selectedMood == mood),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class MoodItem extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;

  const MoodItem({super.key, required this.mood, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? mood.color.withValues(alpha: 0.5)
                : AppColors.primary700,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.gray700 : AppColors.primary600,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: mood.color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 8),
        Text(
          mood.label,
          style: AppTextStyles.labelStatus12w500.copyWith(
            color: isSelected ? AppColors.gray700 : AppColors.gray400,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
