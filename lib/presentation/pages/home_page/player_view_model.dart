import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final _audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

class PlayerState {
  final String? playingPostId;
  final bool isPlaying;

  PlayerState({this.playingPostId, this.isPlaying = false});
}

class PlayerViewModel extends Notifier<PlayerState> {
  @override
  PlayerState build() {
    final player = ref.read(_audioPlayerProvider);

    // 노래가 끝까지 재생되면 자동으로 정지 상태로 바꾸는 리스너
    player.playerStateStream.listen((audioState) {
      if (audioState.processingState == ProcessingState.completed) {
        state = PlayerState(playingPostId: null, isPlaying: false);
      }
    });

    return PlayerState();
  }

  Future<void> togglePlay(String postId, String? previewUrl) async {
    final player = ref.read(_audioPlayerProvider);

    // 1. 같은 곡을 눌렀을 때 (일시정지/재생)
    if (state.playingPostId == postId) {
      if (state.isPlaying) {
        await player.pause();
        state = PlayerState(playingPostId: postId, isPlaying: false);
      } else {
        // 재생 시에도 바로 상태를 바꾸고 play 실행
        state = PlayerState(playingPostId: postId, isPlaying: true);
        await player.play();
      }
      return;
    }

    // 2. 새로운 곡을 눌렀을 때
    if (previewUrl == null || previewUrl.isEmpty) return;

    try {
      state = PlayerState(playingPostId: postId, isPlaying: true);

      await player.stop();
      await player.setUrl(previewUrl);
      await player.play();
    } catch (e) {
      debugPrint("음악 재생 오류: $e");
      state = PlayerState(playingPostId: null, isPlaying: false);
    }
  }
}

final playerViewModelProvider = NotifierProvider<PlayerViewModel, PlayerState>(
  PlayerViewModel.new,
);
