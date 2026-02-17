import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page.dart';

class HomeEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const HomeEmptyState({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Stack(
        children: [
          ListView(), // 빈 리스트뷰 (RefreshIndicator 동작용)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '아직 작성된 피드가 없어요.\n첫 글을 작성해보세요!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyPrimary16w600.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WritePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('새 글 작성'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
