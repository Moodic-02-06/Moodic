import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/data/data_source/fire_store_post_data_source.dart';
import 'package:flutter_moodic/data/dto/music_dto.dart';
import 'package:flutter_moodic/data/dto/post_dto.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final FirestorePostDataSource dataSource;

  PostRepositoryImpl(this.dataSource);

  @override
  Future<List<Post>> fetchFeeds({int limit = 20}) async {
    final currentUserId = 'CURRENT_USER_ID';
    final dtos = await dataSource.fetchFeeds(
      limit: limit,
      currentUserId: currentUserId,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Post> fetchPostById(String postId) async {
    final currentUserId = 'CURRENT_USER_ID';
    final dto = await dataSource.fetchPostById(postId, currentUserId);
    return dto.toEntity();
  }

  @override
  Future<void> toggleLike(
    String postId,
    String userId,
    bool isCurrentlyLiked,
  ) async {
    return dataSource.toggleLike(postId, userId, isCurrentlyLiked);
  }

  @override
  Future<List<Comment>> fetchComments(String postId) async {
    final dtos = await dataSource.fetchComments(postId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> addComment(String postId, String userId, String content) {
    return dataSource.addComment(postId, userId, content);
  }

  @override
  Future<void> createPost(Post post) async {
    final dto = PostDto(
      postId: post.postId,
      userId: post.userId,
      mood: post.mood,
      content: post.content,
      music: MusicDto.fromEntity(post.music),
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      createdAt: Timestamp.fromDate(post.createdAt),
      updatedAt: Timestamp.fromDate(post.updatedAt),
    );

    await dataSource.createPost(dto);
  }

  @override
  Future<void> updatePost(Post post) async {
    final dto = PostDto(
      postId: post.postId,
      userId: post.userId,
      mood: post.mood,
      content: post.content,
      music: MusicDto.fromEntity(post.music),
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      createdAt: Timestamp.fromDate(post.createdAt),
      updatedAt: Timestamp.fromDate(post.updatedAt),
    );
    await dataSource.updatePost(dto);
  }

  @override
  Future<void> deletePost(String postId) async {
    return dataSource.deletePost(postId);
  }
}
