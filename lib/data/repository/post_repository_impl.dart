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

  /// 피드 최신 20개 가져오기 (Stream)
  @override
  Stream<List<Post>> getFeedsStream({
    int limit = 20,
    String? userId,
    String? authorId,
  }) {
    return dataSource.getFeedsStream(limit: limit, authorId: authorId).asyncMap(
      (dtos) async {
        if (dtos.isEmpty) return <Post>[];

        // 로그인 안함 -> 전부 좋아요 false
        if (userId == null) {
          return dtos.map((dto) => dto.toEntity()).toList();
        }

        // 로그인 함 -> 좋아요 여부 확인
        final feedIds = dtos.map((e) => e.postId).toList();
        final likedSet = await dataSource.fetchLikedFeedIds(userId, feedIds);

        return dtos.map((dto) {
          final isLiked = likedSet.contains(dto.postId);
          return dto.toEntity().copyWith(isLikedByMe: isLiked);
        }).toList();
      },
    );
  }

  /// 내가 좋아요한 피드 목록 가져오기
  @override
  Stream<List<Post>> getLikedPostsStream(String userId) {
    return dataSource.fetchLikedFeedsStream(userId).map((dtos) {
      return dtos.map((dto) => dto.toEntity()).toList();
    });
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

  /// 특정 포스트 가져오기 (Stream)
  @override
  Stream<Post> getPostStream(String postId, String? userId) {
    return dataSource.getPostStream(postId).asyncMap((dto) async {
      bool isLiked = false;
      if (userId != null) {
        final likedSet = await dataSource.fetchLikedFeedIds(userId, [
          dto.postId,
        ]);
        isLiked = likedSet.contains(dto.postId);
      }
      return dto.toEntity().copyWith(isLikedByMe: isLiked);
    });
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

  /// 댓글 조회 (Stream)
  @override
  Stream<List<Comment>> getCommentsStream(String postId) {
    return dataSource.getCommentsStream(postId).map((dtos) {
      return dtos.map((dto) => dto.toEntity()).toList();
    });
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
      paths.asMap().entries.map((entry) async {
        final index = entry.key;
        final path = entry.value;

        // 이미 원격 URL인 경우 업로드 생략
        if (path.startsWith('http')) {
          return path;
        }

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

  /// 댓글 삭제
  @override
  Future<void> deleteComment(String postId, String commentId) async {
    return dataSource.deleteComment(postId, commentId);
  }
}
