import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedMusicNotifier extends Notifier<Music?> {
  @override
  Music? build() {
    return null;
  }

  void select(Music music) {
    state = music;
  }

  void clear() {
    state = null;
  }

  void set(Music? music) {
    state = music;
  }
}

final selectedMusicProvider = NotifierProvider<SelectedMusicNotifier, Music?>(
  SelectedMusicNotifier.new,
);
