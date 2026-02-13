import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/core/utils/dialog_util.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/music_search_page/music_search_page.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/image_upload_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/mood_selector_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/widgets/story_input_section.dart';
import 'package:flutter_moodic/presentation/pages/write_page/selected_music_provider.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page_view_model.dart';
import 'package:flutter_moodic/presentation/provider/global_music_player_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/music_display_card.dart';
import 'package:flutter_moodic/presentation/widgets/primary_bottom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritePage extends ConsumerStatefulWidget {
  final Post? post;
  const WritePage({super.key, this.post});

  @override
  ConsumerState<WritePage> createState() => _WritePageState();
}

class _WritePageState extends ConsumerState<WritePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.post != null) {
        ref.read(writeViewModelProvider.notifier).initEdit(widget.post!);
      } else {
        ref.read(writeViewModelProvider.notifier).initNewPost();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final writeState = ref.watch(writeViewModelProvider);
    final isEdit = widget.post != null;
    final selectedMusic = ref.watch(selectedMusicProvider);
    final userAsync = ref.watch(userProvider);
    final bool isReady =
        selectedMusic != null && writeState.content.trim().isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final viewModel = ref.read(writeViewModelProvider.notifier);

        if (!viewModel.isChanged) {
          Navigator.pop(context);
          return;
        }

        final canExit = await DialogUtil.showConfirmBoolDialog(
          context,
          title: const Text('작성 중인 내용이 있어요'),
          content: const Text('저장하지 않고 나가시겠어요?'),
          confirmText: '나가기',
        );

        if (canExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
        bottomNavigationBar: PrimaryBottomButton(
          label: isEdit ? '수정하기' : '저장하기',
          isLoading: writeState.isLoading,
          onPressed: (isReady && userAsync.hasValue && userAsync.value != null)
              ? () async {
                  final user = userAsync.value!;

                  try {
                    final notifier = ref.read(writeViewModelProvider.notifier);

                    if (isEdit) {
                      await notifier.updatePost(
                        user.uid,
                        user.nickname,
                        user.profileImage ?? '',
                      );
                    } else {
                      await notifier.createPost(
                        user.uid,
                        user.nickname,
                        user.profileImage ?? '',
                      );
                    }

                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                }
              : null,
        ),
      ),
    );
  }
}

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
    final globalMusicState = ref.watch(globalMusicPlayerProvider);

    if (music == null) {
      return const SizedBox();
    }
    return MusicDisplayCard(
      music: music,
      isPlaying:
          globalMusicState.playingId == music.id && globalMusicState.isPlaying,
      showDeleteButton: true,
      onPlayPressed: () {
        ref
            .read(globalMusicPlayerProvider.notifier)
            .togglePlay(music.id, music.previewUrl);
      },
      onDelete: () {
        ref.read(selectedMusicProvider.notifier).clear();
      },
      onSelect: null,
    );
  }
}
