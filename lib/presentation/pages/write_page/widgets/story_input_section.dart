import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

//////////////////////////////////////////////////
/// 4️⃣ 이야기 입력
//////////////////////////////////////////////////

class StoryInputSection extends StatelessWidget {
  const StoryInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary600),
      ),
      child: Stack(
        children: [
          Text(
            '이야기를 남겨봅시다',
            style: AppTextStyles.bodyPrimary16w500.copyWith(
              color: AppColors.gray700,
            ),
          ),

          const Positioned(
            bottom: 0,
            right: 0,
            child: Text('10/280', style: AppTextStyles.labelStatus12w500),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: TextField(
              maxLines: null,
              expands: true,
              style: AppTextStyles.bodyPrimary16w500.copyWith(
                color: AppColors.gray900,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '오늘의 이야기를 적어주세요...',
                hintStyle: TextStyle(color: AppColors.gray300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
