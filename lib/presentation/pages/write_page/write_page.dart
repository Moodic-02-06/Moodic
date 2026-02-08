import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/image_upload_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/mood_selector_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/story_input_section.dart';

class WritePage extends StatelessWidget {
  const WritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary900,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '보관함',
              style: AppTextStyles.bodyPrimary16w500.copyWith(
                color: AppColors.text600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          MoodSelectorSection(),
          SizedBox(height: 24),

          MusicSelectSection(),
          SizedBox(height: 24),

          ImageUploadSection(),
          SizedBox(height: 24),

          StoryInputSection(),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////
/// 2️⃣ 음악 선택 섹션
//////////////////////////////////////////////////

class MusicSelectSection extends StatelessWidget {
  const MusicSelectSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기분과 어울리는 음악을 선택해주세요.',
          style: AppTextStyles.bodyPrimary16w500.copyWith(
            color: AppColors.text600,
          ),
        ),

        const SizedBox(height: 12),

        const MusicSearchBar(),

        const SizedBox(height: 12),

        const SelectedMusicCard(),
      ],
    );
  }
}

class MusicSearchBar extends StatelessWidget {
  const MusicSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.primary600),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.gray300),

          const SizedBox(width: 8),

          Text(
            '음악 검색..',
            style: AppTextStyles.bodyPrimary16w500.copyWith(
              color: AppColors.gray300,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedMusicCard extends StatelessWidget {
  const SelectedMusicCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: AppColors.primary600),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage('https://placehold.co/44x44'),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '춘몽',
                    style: AppTextStyles.bodyPrimary16w600.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),

                  Text(
                    '현서 (HYUNSEO)',
                    style: AppTextStyles.labelStatus12w500.copyWith(
                      color: AppColors.text600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Icon(Icons.close, color: AppColors.gray300),
        ],
      ),
    );
  }
}
