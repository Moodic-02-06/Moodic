import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_moodic/presentation/pages/search_page/widgets/search_app_bar.dart';
import 'package:flutter_moodic/presentation/provider/global_music_player_provider.dart';
import 'package:flutter_moodic/presentation/provider/music_provider.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_moodic/presentation/widgets/music_display_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  MoodType? selectedMood;

  Future<void> _togglePlay(Music music) async {
    await ref
        .read(globalMusicPlayerProvider.notifier)
        .togglePlay(music.id, music.previewUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        controller: _controller,
        focusNode: _focusNode,
        onSearch: _search,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          /// ================= 인기 감정 =================
          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 16),

                const Text('감정으로 검색', style: AppTextStyles.titlePrimary20w600),

                const SizedBox(height: 12),

                SizedBox(
                  height: 40,

                  child: ListView(
                    scrollDirection: Axis.horizontal,

                    children: MoodType.values.map((mood) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),

                          // 푸쉬 네임드, 고 네임드, path 파라미터로 넘기기
                          onTap: () {
                            context.push('/search/result', extra: mood);
                          },

                          child: MoodBadge(moodLabel: mood.label),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          /// ================= 추천 음악 =================
          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text('음악으로 검색', style: AppTextStyles.titlePrimary20w600),

                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, child) {
                    final musicState = ref.watch(musicProvider);
                    final globalMusicState = ref.watch(
                      globalMusicPlayerProvider,
                    );

                    return musicState.when(
                      loading: () => const SizedBox(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary600,
                          ),
                        ),
                      ),
                      error: (e, _) => SizedBox(
                        height: 400,
                        child: Center(
                          child: Text(
                            '검색에 실패했습니다 😢',
                            style: AppTextStyles.bodyPrimary16w500.copyWith(
                              color: AppColors.gray300,
                            ),
                          ),
                        ),
                      ),
                      data: (musics) {
                        if (musics.isEmpty) {
                          return SizedBox(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: AppColors.gray300,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '검색 결과가 없어요',
                                    style: AppTextStyles.bodyPrimary16w500
                                        .copyWith(color: AppColors.gray300),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: musics.map((music) {
                            final isPlaying =
                                globalMusicState.playingId == music.id &&
                                globalMusicState.isPlaying;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: MusicDisplayCard(
                                music: music,
                                isPlaying: isPlaying,
                                onPlayPressed: () => _togglePlay(music),
                                onSelect: () {
                                  // 음악으로 게시글 검색 결과 페이지로 이동
                                  context.push('/search/result', extra: music);
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 검색 실행
  void _search() {
    final keyword = _controller.text.trim();

    if (keyword.isEmpty) return;

    ref.read(musicProvider.notifier).search(keyword);
  }
}
