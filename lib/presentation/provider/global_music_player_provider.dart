import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// 전역 오디오 플레이어 인스턴스
final _audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

class GlobalMusicState {
  final String? playingId; // 현재 재생 중인 음악/포스트 ID
  final bool isPlaying;

  GlobalMusicState({this.playingId, this.isPlaying = false});
}

class GlobalMusicPlayerNotifier extends Notifier<GlobalMusicState> {
  late final AudioPlayer _player;
  StreamSubscription? _playerStateSubscription;

  @override
  GlobalMusicState build() {
    _player = ref.read(_audioPlayerProvider);

    // 노래가 끝까지 재생되면 자동으로 정지 상태로 변경
    _playerStateSubscription = _player.playerStateStream.listen((audioState) {
      if (audioState.processingState == ProcessingState.completed) {
        state = GlobalMusicState(playingId: null, isPlaying: false);
      }
    });

    // dispose 시 스트림 구독 해제
    ref.onDispose(() => _playerStateSubscription?.cancel());

    return GlobalMusicState();
  }

  /// 음악 재생/일시정지 토글
  Future<void> togglePlay(String id, String? previewUrl) async {
    // previewUrl 없으면 재생 불가
    if (previewUrl == null || previewUrl.isEmpty) {
      debugPrint('[MusicPlayer] previewUrl이 없어 재생할 수 없습니다: id=$id');
      return;
    }

    // 1. 같은 곡을 눌렀을 때 (일시정지/재생)
    if (state.playingId == id) {
      if (state.isPlaying) {
        await _player.pause();
        state = GlobalMusicState(playingId: id, isPlaying: false);
      } else {
        state = GlobalMusicState(playingId: id, isPlaying: true);
        await _player.play();
      }
      return;
    }

    // 2. 새로운 곡을 눌렀을 때
    try {
      // 상태 먼저 업데이트 (UI 반응성 향상)
      state = GlobalMusicState(playingId: id, isPlaying: true);

      await _player.stop(); // 이전 곡 정지
      await _player.setUrl(previewUrl);
      await _player.play();
    } catch (e) {
      debugPrint('[MusicPlayer] 재생 오류: $e');
      state = GlobalMusicState(playingId: null, isPlaying: false);
    }
  }

  /// 강제 정지 (화면 이탈 시 등)
  Future<void> stop() async {
    await _player.stop();
    state = GlobalMusicState(playingId: null, isPlaying: false);
  }
}

final globalMusicPlayerProvider =
    NotifierProvider<GlobalMusicPlayerNotifier, GlobalMusicState>(
      GlobalMusicPlayerNotifier.new,
    );
