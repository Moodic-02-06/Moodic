import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

//////////////////////////////////////////////////
/// 3️⃣ 이미지 업로드
//////////////////////////////////////////////////

class ImageUploadSection extends StatelessWidget {
  const ImageUploadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary700,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary600),
          ),
          child: Text(
            '0/10',
            style: AppTextStyles.labelStatus12w500.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '* 첫 번째 사진이 대표 사진입니다.',
          style: AppTextStyles.labelStatus12w500.copyWith(
            color: AppColors.gray300,
          ),
        ),
      ],
    );
  }
}
