import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/data/data_source/fire_store_post_data_source.dart';
import 'package:flutter_moodic/data/data_source/firebase_storage_data_source.dart';
import 'package:flutter_moodic/data/dto/music_dto.dart';
import 'package:flutter_moodic/data/dto/post_dto.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final FirestorePostDataSource dataSource;
  final FirebaseStorageDataSource storageDataSource;

  PostRepositoryImpl(this.dataSource, this.storageDataSource);

  /// 피드 최신 20개 가져오기
  @override
  Future<List<Post>> fetchFeeds({int limit = 20, String? userId}) async {
    final dtos = await dataSource.fetchFeeds(
      limit: limit,
      currentUserId: userId,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  /// 월별 포스트 가져오기
  @override
  Future<List<Post>> fetchPostsByMonth(
    String userId,
    int year,
    int month,
  ) async {
    final dtos = await dataSource.fetchPostsByMonth(userId, year, month);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  /// 특정 포스트 가져오기 (상세화면)
  @override
  Future<Post> fetchPostById(String postId, String? userId) async {
    final dto = await dataSource.fetchPostById(postId, userId);
    return dto.toEntity();
  }

  /// 좋아요 토글
  @override
  Future<void> toggleLike(
    String postId,
    String userId,
    bool isCurrentlyLiked,
  ) async {
    return dataSource.toggleLike(postId, userId, isCurrentlyLiked);
  }

  /// 댓글 조회
  @override
  Future<List<Comment>> fetchComments(String postId) async {
    final dtos = await dataSource.fetchComments(postId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  /// 댓글 추가
  @override
  Future<void> addComment(
    String postId,
    String userId,
    String content,
    String userNickname,
    String userImageUrl,
  ) {
    return dataSource.addComment(
      postId,
      userId,
      content,
      userNickname,
      userImageUrl,
    );
  }

  /// 이미지 업로드
  @override
  Future<List<String>> uploadImages(String userId, List<String> paths) async {
    return Future.wait(
      paths.asMap().entries.map((entry) {
        final index = entry.key;
        final path = entry.value;

        return storageDataSource.uploadImage(
          path: path,
          fileName:
              'posts/$userId/${DateTime.now().millisecondsSinceEpoch}_$index.jpg',
        );
      }),
    );
  }

  /// 포스트 작성
  @override
  Future<void> createPost(Post post) async {
    final dto = PostDto(
      postId: post.postId,
      userId: post.userId,
      userNickname: post.userNickname,
      userImageUrl: post.userImageUrl,
      mood: post.mood,
      content: post.content,
      music: MusicDto.fromEntity(post.music),
      imageUrls: post.imageUrls,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      isLikedByMe: post.isLikedByMe,
      createdAt: Timestamp.fromDate(post.createdAt),
      updatedAt: Timestamp.fromDate(post.updatedAt),
    );

    await dataSource.createPost(dto);
  }

  /// 포스트 수정
  @override
  Future<void> updatePost(Post post) async {
    final dto = PostDto(
      postId: post.postId,
      userId: post.userId,
      userNickname: post.userNickname,
      userImageUrl: post.userImageUrl,
      mood: post.mood,
      content: post.content,
      music: MusicDto.fromEntity(post.music),
      imageUrls: post.imageUrls,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      isLikedByMe: post.isLikedByMe,
      createdAt: Timestamp.fromDate(post.createdAt),
      updatedAt: Timestamp.fromDate(post.updatedAt),
    );
    await dataSource.updatePost(dto);
  }

  /// 포스트 삭제
  @override
  Future<void> deletePost(String postId) async {
    return dataSource.deletePost(postId);
  }
}
