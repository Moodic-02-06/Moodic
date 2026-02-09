import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_moodic/presentation/music_search_page/widgets/music_search_item.dart';
import 'package:flutter_moodic/presentation/provider/music_provider.dart';
import 'package:flutter_moodic/presentation/provider/search_debounce_provider.dart';
import 'package:flutter_moodic/presentation/provider/search_keyword_provider.dart';
import 'package:flutter_moodic/presentation/pages/write_page/selected_music_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class MusicSearchPage extends ConsumerStatefulWidget {
  const MusicSearchPage({super.key});

  @override
  ConsumerState<MusicSearchPage> createState() => _MusicSearchPageState();
}

class _MusicSearchPageState extends ConsumerState<MusicSearchPage> {
  final AudioPlayer _player = AudioPlayer(); // 페이지 전체 공유
  String? _currentlyPlayingId; // 현재 재생 중인 곡 ID

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(musicProvider.notifier).clear();
      ref.read(searchKeywordProvider.notifier).clear();
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _currentlyPlayingId = null;
          });
          _player.stop();
          _player.seek(Duration.zero);
        }
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(Music music) async {
    final isSameMusic = _currentlyPlayingId == music.id;

    if (isSameMusic) {
      await _player.stop();
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
        });
      }
    } else {
      setState(() {
        _currentlyPlayingId = music.id;
      });

      try {
        await _player.setUrl(music.previewUrl);
        await _player.play();
      } catch (e) {
        debugPrint('Audio Play Error: $e');
        if (mounted) {
          setState(() {
            _currentlyPlayingId = null;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('미리듣기 재생에 실패했습니다.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debounce 활성화
    ref.watch(searchDebounceProvider);

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
                          final isPlaying = _currentlyPlayingId == music.id;
                          return MusicSearchItem(
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

//////////////////////////////////////////////////
/// 검색 입력창
//////////////////////////////////////////////////

class SearchInput extends ConsumerStatefulWidget {
  final void Function(String) onSearch;

  // super.key 사용 → 경고 없음d
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
            fillColor: Colors.transparent, // Uses container color
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
