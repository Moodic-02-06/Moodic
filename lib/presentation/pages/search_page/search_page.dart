import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 80,
              color: AppColors.gray500,
            ),
            const SizedBox(height: 24),
            Text(
              '검색 기능을 준비 중이에요!',
              style: AppTextStyles.bodyPrimary16w600.copyWith(
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '조금만 기다려주세요',
              style: AppTextStyles.bodyPrimary16w600.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
