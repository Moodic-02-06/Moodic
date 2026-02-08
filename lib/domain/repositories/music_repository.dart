import '../entity/music.dart';

abstract class MusicRepository {
  Future<List<Music>> searchMusic(String keyword);
}
