import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/entity/post.dart';

abstract class PostRepository {
  /// 피드 최신 20개 가져오기
  Stream<List<Post>> getFeedsStream({
    int limit = 20,
    String? userId,
    String? authorId,
  });

  /// 월별 포스트 가져오기
  Future<List<Post>> fetchPostsByMonth(String userId, int year, int month);

  /// 이미지 업로드
  Future<List<String>> uploadImages(String userId, List<String> images);

  /// 특정 포스트 가져오기 (상세화면)
  Stream<Post> getPostStream(String postId, String? userId);

  /// 좋아요 토글
  Future<void> toggleLike(String postId, String userId, bool isCurrentlyLiked);

  /// 댓글 조회
  Stream<List<Comment>> getCommentsStream(String postId);

  /// 댓글 추가
  Future<void> addComment(
    String postId,
    String userId,
    String content,
    String nickname,
    String profileImageUrl,
  );

  /// 포스트 작성
  Future<void> createPost(Post post);

  /// 포스트 수정
  Future<void> updatePost(Post post);

  /// 포스트 삭제
  Future<void> deletePost(String postId);

  /// 댓글 삭제
  Future<void> deleteComment(String postId, String commentId);
}
