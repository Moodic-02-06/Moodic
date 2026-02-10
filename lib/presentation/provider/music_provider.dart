import 'package:flutter_moodic/domain/repository/music_repository.dart';
import 'package:flutter_moodic/domain/usecase/search_music_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_moodic/data/data_source/itunes_api.dart';
import 'package:flutter_moodic/data/repository/music_repository_impl.dart';

import 'package:flutter_moodic/domain/entity/music.dart';

final musicRemoteDataSourceProvider = Provider<ItunesApi>((ref) {
  return ItunesApi();
});

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepositoryImpl(ref.read(musicRemoteDataSourceProvider));
});

final searchMusicUseCaseProvider = Provider<SearchMusicUseCase>((ref) {
  return SearchMusicUseCase(ref.read(musicRepositoryProvider));
});

final musicProvider = AsyncNotifierProvider<MusicNotifier, List<Music>>(
  MusicNotifier.new,
);

class MusicNotifier extends AsyncNotifier<List<Music>> {
  late final SearchMusicUseCase _useCase;

  @override
  Future<List<Music>> build() async {
    _useCase = ref.read(searchMusicUseCaseProvider);

    return [];
  }

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) return;

    state = const AsyncValue.loading();

    try {
      final result = await _useCase.call(keyword);

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 초기화
  void clear() {
    state = const AsyncValue.data([]);
  }
}
