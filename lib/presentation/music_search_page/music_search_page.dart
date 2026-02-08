import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_moodic/presentation/provider/music_provider.dart';
import 'package:flutter_moodic/presentation/provider/selected_music_provider.dart';
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
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay(Music music) async {
    if (_currentlyPlayingId == music.id && _player.playing) {
      await _player.stop();
      setState(() => _currentlyPlayingId = null);
    } else {
      await _player.setUrl(music.previewUrl);
      await _player.play();
      setState(() => _currentlyPlayingId = music.id);

      // 재생 끝나면 자동으로 현재 재생 곡 null
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _currentlyPlayingId = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary900,
      appBar: AppBar(title: const Text('음악 검색')),
      body: SafeArea(
        child: Column(
          children: [
            _SearchInput(
              onSearch: (value) {
                ref.read(musicProvider.notifier).search(value);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final musicState = ref.watch(musicProvider);

                  return musicState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        '검색 실패 😢',
                        style: AppTextStyles.bodyPrimary16w500.copyWith(
                          color: AppColors.gray300,
                        ),
                      ),
                    ),
                    data: (musics) {
                      if (musics.isEmpty) {
                        return Center(
                          child: Text(
                            '검색 결과가 없어요',
                            style: AppTextStyles.bodyPrimary16w500.copyWith(
                              color: AppColors.gray300,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: musics.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
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

class _SearchInput extends ConsumerStatefulWidget {
  final void Function(String) onSearch;

  const _SearchInput({super.key, required this.onSearch});

  @override
  ConsumerState<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends ConsumerState<_SearchInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        style: AppTextStyles.bodyPrimary16w500.copyWith(
          color: AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: '노래 / 가수 검색',
          prefixIcon: const Icon(Icons.search, color: AppColors.gray300),
          filled: true,
          fillColor: AppColors.primary700,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////
/// 검색 결과 아이템
//////////////////////////////////////////////////

class MusicSearchItem extends StatelessWidget {
  final Music music;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final VoidCallback onSelect;

  const MusicSearchItem({
    super.key,
    required this.music,
    required this.isPlaying,
    required this.onPlayPressed,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: AppColors.primary600),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary600,
                  backgroundImage: music.artwork.isNotEmpty
                      ? NetworkImage(music.artwork)
                      : null,
                  child: music.artwork.isEmpty
                      ? const Icon(
                          Icons.music_note_outlined,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        music.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                      Text(
                        music.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelStatus12w500.copyWith(
                          color: AppColors.text600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPlayPressed,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: AppColors.gray300,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSelect,
            child: const Icon(
              Icons.add_circle_outline,
              color: AppColors.gray300,
            ),
          ),
        ],
      ),
    );
  }
}
