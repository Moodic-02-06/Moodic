import '../repositories/music_repository.dart';
import '../entity/music.dart';

class SearchMusicUseCase {
  final MusicRepository repo;

  SearchMusicUseCase(this.repo);

  Future<List<Music>> call(String keyword) async {
    return await repo.searchMusic(keyword);
  }
}
