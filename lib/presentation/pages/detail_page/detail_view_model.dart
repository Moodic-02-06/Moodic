import 'dart:async';

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
  StreamSubscription<Post>? _postSubscription;
  StreamSubscription<List<Comment>>? _commentSubscription;

  DetailViewModel(this.postId);

  @override
  DetailState build() {
    ref.onDispose(() {
      _postSubscription?.cancel();
      _commentSubscription?.cancel();
    });

    _subscribe();

    return const DetailState(isLoading: true);
  }

  void _subscribe() {
    final currentUserId = ref.read(userProvider).value?.uid;
    final repository = ref.read(postRepositoryProvider);

    _postSubscription = repository
        .getPostStream(postId, currentUserId)
        .listen(
          (post) {
            state = state.copyWith(post: post, isLoading: false);
          },
          onError: (e) {
            state = state.copyWith(error: e.toString(), isLoading: false);
          },
        );

    _commentSubscription = repository
        .getCommentsStream(postId)
        .listen(
          (comments) {
            state = state.copyWith(comments: comments);
          },
          onError: (e) {
            debugPrint('댓글 로드 실패: $e');
          },
        );
  }

  Future<void> addComment(String content, UserEntity user) async {
    try {
      await ref
          .read(postRepositoryProvider)
          .addComment(
            postId,
            user.uid,
            content,
            user.nickname,
            user.profileImage ?? '',
          );
      // Stream이 자동 업데이트
    } catch (e) {
      state = state.copyWith(error: '댓글 등록 실패');
    }
  }

  Future<void> toggleLike(UserEntity user) async {
    final currentPost = state.post;
    if (currentPost == null) return;

    try {
      await ref
          .read(toggleLikeUseCaseProvider)
          .call(currentPost.postId, user.uid, currentPost.isLikedByMe);
      // Stream이 자동 업데이트
    } catch (e) {
      debugPrint('좋아요 실패: $e');
    }
  }

  void clearPost() {
    state = state.copyWith(post: null);
  }

  Future<void> deletePost(String postId) async {
    try {
      await ref.read(deletePostUseCaseProvider).execute(postId);
      clearPost();
    } catch (e) {
      debugPrint('게시글 삭제 실패: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await ref.read(postRepositoryProvider).deleteComment(postId, commentId);
    } catch (e) {
      debugPrint('댓글 삭제 실패: $e');
      state = state.copyWith(error: '댓글 삭제 실패');
    }
  }
}

final detailViewModelProvider =
    NotifierProvider.family<DetailViewModel, DetailState, String>(
      DetailViewModel.new,
    );
