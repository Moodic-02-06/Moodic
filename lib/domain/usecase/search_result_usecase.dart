import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

/// 기분으로 게시글 검색 UseCase
class SearchByMoodUseCase {
  final PostRepository _repository;

  SearchByMoodUseCase(this._repository);

  Future<List<Post>> call(String mood, String? userId) async {
    return _repository.fetchPostsByMood(mood, userId);
  }
}

/// 음악 ID로 게시글 검색 UseCase
class SearchByMusicIdUseCase {
  final PostRepository _repository;

  SearchByMusicIdUseCase(this._repository);

  Future<List<Post>> call(String musicId, String? userId) async {
    return _repository.fetchPostsByMusicId(musicId, userId);
  }
}
