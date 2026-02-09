import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class MockPostRepository implements PostRepository {
  final List<Post> _mockPosts = List.generate(
    5,
    (index) => Post(
      postId: 'post_$index',
      userId: 'user_$index',
      userName: '사용자 이름 $index',
      userImageUrl: 'https://example.com/user_$index.jpg',
      mood: '행복',
      content: '목 데이터 예시 글 $index',
      music: Music(
        id: 'music_$index',
        title: '곡 제목 $index',
        artist: '아티스트 $index',
        previewUrl: '',
        artwork: '',
        trackUrl: '',
      ),
      imageUrls: [],
      likeCount: index * 3,
      commentCount: index,
      createdAt: DateTime.now().subtract(Duration(hours: index)),
      updatedAt: DateTime.now().subtract(Duration(hours: index)),
    ),
  );

  @override
  Future<void> addComment(String postId, String userId, String content) async {
    // 목 데이터라 실제 구현은 필요 없음
  }

  @override
  Future<void> createPost(Post post) async {}

  @override
  Future<void> deletePost(String postId) async {}

  @override
  Future<List<Post>> fetchFeeds({int limit = 20}) async {
    return _mockPosts.take(limit).toList();
  }

  @override
  Future<Post> fetchPostById(String postId) async {
    return _mockPosts.firstWhere((p) => p.postId == postId);
  }

  @override
  Future<void> toggleLike(
    String postId,
    String userId,
    bool isCurrentlyLiked,
  ) async {}

  @override
  Future<void> updatePost(Post post) async {}

  @override
  Future<List<Comment>> fetchComments(String postId) async {
    return List.generate(
      3,
      (index) => Comment(
        commentId: 'comment_${postId}_$index',
        postId: postId,
        userId: 'user_$index',
        content: '목 댓글 $index',
        createdAt: DateTime.now().subtract(Duration(minutes: index * 5)),
      ),
    );
  }
}
