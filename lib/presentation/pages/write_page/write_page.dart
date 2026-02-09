import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/music_search_page/music_search_page.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/image_upload_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/mood_selector_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/story_input_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/selected_music_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritePage extends ConsumerWidget {
  const WritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          SizedBox(height: 20),

          MusicSelectSection(),
          SizedBox(height: 20),

          ImageUploadSection(),
          SizedBox(height: 20),

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
            color: AppColors.gray700,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MusicSearchPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary700,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.primary600),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.gray400),
            const SizedBox(width: 8),
            Text(
              '음악 검색..',
              style: AppTextStyles.bodyPrimary16w500.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedMusicCard extends ConsumerWidget {
  const SelectedMusicCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(selectedMusicProvider);

    if (music == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary600),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary600,
                backgroundImage: music.artwork.isNotEmpty
                    ? NetworkImage(music.artwork)
                    : null,
                child: music.artwork.isEmpty
                    ? const Icon(Icons.music_note_outlined, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    music.title,
                    style: AppTextStyles.bodyPrimary16w600.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),

                  Text(
                    music.artist,
                    style: AppTextStyles.labelStatus12w500.copyWith(
                      color: AppColors.text600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// 삭제 버튼
          GestureDetector(
            onTap: () {
              ref.read(selectedMusicProvider.notifier).clear();
            },
            child: const Icon(Icons.close, color: AppColors.gray300),
          ),
        ],
      ),
    );
  }
}
