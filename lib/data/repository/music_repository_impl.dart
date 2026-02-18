import 'package:flutter_moodic/data/data_source/post_remote_data_source.dart';

import '../../domain/repository/music_repository.dart';
import '../data_source/itunes_api.dart';
import '../../domain/entity/music.dart';
import '../../domain/entity/post.dart';
import '../../domain/entity/mood_type.dart';

class MusicRepositoryImpl implements MusicRepository {
  final ItunesApi api;
  final PostRemoteDataSource postDataSource;

  MusicRepositoryImpl(this.api, this.postDataSource);

  @override
  Future<List<Music>> searchMusic(String keyword) async {
    final dtoList = await api.search(keyword);
    return dtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<Post>> fetchPostsByMusicIds({
    required List<String> musicIds,
    MoodType? mood,
  }) async {
    return await postDataSource.fetchPostsByMusicIds(
      musicIds: musicIds,
      mood: mood,
    );
  }
}
