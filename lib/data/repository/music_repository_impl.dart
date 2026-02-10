import '../../domain/repository/music_repository.dart';
import '../data_source/itunes_api.dart';
import '../../domain/entity/music.dart';

class MusicRepositoryImpl implements MusicRepository {
  final ItunesApi api;

  MusicRepositoryImpl(this.api);

  @override
  Future<List<Music>> searchMusic(String keyword) async {
    final dtoList = await ItunesApi.search(keyword);

    return dtoList.map((dto) => dto.toEntity()).toList();
  }
}
