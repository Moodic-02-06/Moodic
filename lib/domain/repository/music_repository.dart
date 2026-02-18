import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/domain/entity/post.dart';

import '../entity/music.dart';

abstract class MusicRepository {
  Future<List<Music>> searchMusic(String keyword);
  Future<List<Post>> fetchPostsByMusicIds({
    required List<String> musicIds,
    MoodType? mood,
  });
}
