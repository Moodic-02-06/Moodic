import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_moodic/presentation/provider/global_music_player_provider.dart';
import 'package:flutter_moodic/presentation/provider/music_provider.dart';
import 'package:flutter_moodic/presentation/provider/search_debounce_provider.dart';
import 'package:flutter_moodic/presentation/provider/search_keyword_provider.dart';
import 'package:flutter_moodic/presentation/pages/write_page/selected_music_provider.dart';
import 'package:flutter_moodic/presentation/widgets/music_display_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSearchPage extends ConsumerStatefulWidget {
  const MusicSearchPage({super.key});

  @override
  ConsumerState<MusicSearchPage> createState() => _MusicSearchPageState();
}

class _MusicSearchPageState extends ConsumerState<MusicSearchPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(musicProvider.notifier).clear();
      ref.read(searchKeywordProvider.notifier).clear();
    });
  }

  Future<void> _togglePlay(Music music) async {
    await ref
        .read(globalMusicPlayerProvider.notifier)
        .togglePlay(music.id, music.previewUrl);
  }

  @override
  Widget build(BuildContext context) {
    // Debounce 활성화
    ref.watch(searchDebounceProvider);

    // 전역 플레이어 상태 구독
    final globalMusicState = ref.watch(globalMusicPlayerProvider);

    return Scaffold(
      backgroundColor: AppColors.primary900,
      appBar: AppBar(
        backgroundColor: AppColors.primary900,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchInput(
              onSearch: (value) {
                ref.read(searchKeywordProvider.notifier).set(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final musicState = ref.watch(musicProvider);

                  return musicState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary600,
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        '검색에 실패했습니다 😢',
                        style: AppTextStyles.bodyPrimary16w500.copyWith(
                          color: AppColors.gray300,
                        ),
                      ),
                    ),
                    data: (musics) {
                      if (musics.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.gray300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '검색 결과가 없어요',
                                style: AppTextStyles.bodyPrimary16w500.copyWith(
                                  color: AppColors.gray300,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: musics.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final music = musics[index];
                          // 전역 상태와 비교하여 재생 여부 확인
                          final isPlaying =
                              globalMusicState.playingId == music.id &&
                              globalMusicState.isPlaying;

                          return MusicDisplayCard(
                            music: music,
                            isPlaying: isPlaying,
                            onPlayPressed: () => _togglePlay(music),
                            onSelect: () {
                              ref
                                  .read(selectedMusicProvider.notifier)
                                  .select(music);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 검색 입력창
class SearchInput extends ConsumerStatefulWidget {
  final void Function(String) onSearch;

  const SearchInput({super.key, required this.onSearch});

  @override
  ConsumerState<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends ConsumerState<SearchInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    widget.onSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: AppTextStyles.bodyPrimary16w500.copyWith(
            color: AppColors.gray900,
          ),
          decoration: InputDecoration(
            hintText: '노래 / 가수 검색',
            hintStyle: AppTextStyles.bodyPrimary16w500.copyWith(
              color: AppColors.gray300,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.gray300),
            suffixIcon: _showClearButton
                ? IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.gray300),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
