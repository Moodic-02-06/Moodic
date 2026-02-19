import 'dart:async';
import 'dart:math' as math;

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
  Timer? _debounceTimer;

  DetailViewModel(this.postId);

  @override
  DetailState build() {
    ref.onDispose(() {
      _postSubscription?.cancel();
      _commentSubscription?.cancel();
      _debounceTimer?.cancel();
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

    // 낙관적 업데이트 이전의 원래 좋아요 상태 캡처 (서버 요청에 사용)
    final wasLiked = currentPost.isLikedByMe;

    // 1. 낙관적 업데이트 (Optimistic Update)
    final isLiked = !wasLiked;

    // 안전장치 강화: 어떤 상황에서도 0 미만으로 내려가지 않도록 함
    final int newLikeCount = math.max(
      0,
      isLiked ? currentPost.likeCount + 1 : currentPost.likeCount - 1,
    );

    final updatedPost = currentPost.copyWith(
      isLikedByMe: isLiked,
      likeCount: newLikeCount,
    );

    // 이전 상태 백업
    final previousPost = currentPost;

    // UI 즉시 갱신
    state = state.copyWith(post: updatedPost);

    // 2. 디바운싱 적용 (서버 요청 제한)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final finalPost = state.post;
      if (finalPost == null) return;

      try {
        // ⚠️ 핵심: wasLiked(원래 상태)를 전달해야 서버 로직이 올바르게 동작함
        // finalPost.isLikedByMe는 낙관적 업데이트로 이미 뒤집힌 값이므로 사용 불가
        await ref
            .read(toggleLikeUseCaseProvider)
            .call(finalPost.postId, user.uid, wasLiked);
      } catch (e) {
        debugPrint('좋아요 실패: $e');
        // 실패 시 롤백
        state = state.copyWith(post: previousPost);
      }
    });
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
