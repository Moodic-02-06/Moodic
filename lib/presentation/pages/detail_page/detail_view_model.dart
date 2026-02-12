import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailState {
  final Post? post;
  final List<Comment> comments;
  final bool isLoading;
  final String? error;

  const DetailState({
    this.post,
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  DetailState copyWith({
    Post? post,
    List<Comment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return DetailState(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DetailViewModel extends Notifier<DetailState> {
  late final String postId;
  DetailViewModel(this.postId);

  @override
  DetailState build() {
    _load();

    return const DetailState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final currentUserId = ref.read(userProvider).value?.uid;

      final post = await ref
          .read(postRepositoryProvider)
          .fetchPostById(postId, currentUserId);

      final comments = await ref
          .read(postRepositoryProvider)
          .fetchComments(postId);
      state = state.copyWith(post: post, comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addComment(String content, UserEntity user) async {
    // 이전 상태 백업
    final previousComments = state.comments;
    final previousPost = state.post;

    // 임시 댓글 생성 (UI에 즉시 보여줄 용도)
    final tempComment = Comment(
      postId: postId,
      commentId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.uid,
      userNickname: user.nickname,
      userImageUrl: user.profileImage ?? '',
      content: content,
      createdAt: DateTime.now(),
    );

    // 선반영
    state = state.copyWith(
      comments: [...state.comments, tempComment],
      post: previousPost?.copyWith(
        commentCount: (previousPost.commentCount) + 1,
      ),
    );

    try {
      // 실제 DB 저장
      await ref
          .read(postRepositoryProvider)
          .addComment(
            postId,
            user.uid,
            content,
            user.nickname,
            user.profileImage ?? '',
          );

      // 서버 데이터와 최종 동기화
      await _load();
    } catch (e) {
      // 실패 시 롤백
      state = state.copyWith(
        comments: previousComments,
        post: previousPost,
        error: '댓글 등록 실패',
      );
    }
  }

  Future<void> toggleLike(UserEntity user) async {
    final currentPost = state.post;
    if (currentPost == null) return;

    final previousPost = currentPost;

    final newIsLiked = !currentPost.isLikedByMe;
    final newLikeCount = newIsLiked
        ? currentPost.likeCount + 1
        : currentPost.likeCount - 1;

    state = state.copyWith(
      post: currentPost.copyWith(
        isLikedByMe: newIsLiked,
        likeCount: newLikeCount,
      ),
    );

    try {
      await ref
          .read(toggleLikeUseCaseProvider)
          .call(currentPost.postId, user.uid, currentPost.isLikedByMe);
    } catch (e) {
      state = state.copyWith(post: previousPost);
      debugPrint('좋아요 실패로 복구됨: $e');
    }
  }

  Future<void> refreshDetail() async {
    try {
      final currentUserId = ref.read(userProvider).value?.uid;
      final post = await ref
          .read(postRepositoryProvider)
          .fetchPostById(postId, currentUserId);

      final comments = await ref
          .read(postRepositoryProvider)
          .fetchComments(postId);

      state = state.copyWith(post: post, comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final detailViewModelProvider =
    NotifierProvider.family<DetailViewModel, DetailState, String>(
      DetailViewModel.new,
    );
