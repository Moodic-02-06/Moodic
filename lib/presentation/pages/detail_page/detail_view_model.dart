import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';

import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/provider/blocked_ids_provider.dart';
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
  bool _mounted = true;

  @override
  DetailState build() {
    ref.onDispose(() {
      _mounted = false;
      _postSubscription?.cancel();
      _commentSubscription?.cancel();
      _debounceTimer?.cancel();
    });

    _subscribe();

    return const DetailState(isLoading: true);
  }

  // 답글 작성 대상 댓글 (null이면 일반 댓글)
  Comment? _replyingToComment;
  Comment? get replyingToComment => _replyingToComment;

  void setReplyingTo(Comment? comment) {
    _replyingToComment = comment;
    state = state.copyWith();
  }

  Future<void> _subscribe() async {
    await ref.read(blockedIdsProvider.notifier).loadBlockedIds();

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
            final blockedIds = ref.read(blockedIdsProvider);
            final filteredComments = comments
                .where(
                  (c) =>
                      !blockedIds.contains(c.commentId) &&
                      !blockedIds.contains(c.userId),
                )
                .toList();
            state = state.copyWith(comments: filteredComments);
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
            parentId: _replyingToComment?.commentId,
          );

      // 알림 전송
      final post = state.post;
      if (post != null) {
        await ref
            .read(createNotificationUseCaseProvider)
            .call(
              userId: post.userId,
              type: 'comment',
              message: '${user.nickname}님이 댓글을 달았습니다.',
              senderId: user.uid,
              senderNickname: user.nickname,
              senderProfileImage: user.profileImage ?? '',
              targetId: post.postId,
            );
      }

      if (!_mounted) return;

      setReplyingTo(null);
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(error: '댓글 등록 실패');
    }
  }

  Future<void> toggleLike(UserEntity user) async {
    final currentPost = state.post;
    if (currentPost == null) return;

    final wasLiked = currentPost.isLikedByMe;
    final isLiked = !wasLiked;
    final int newLikeCount = math.max(
      0,
      isLiked ? currentPost.likeCount + 1 : currentPost.likeCount - 1,
    );

    final updatedPost = currentPost.copyWith(
      isLikedByMe: isLiked,
      likeCount: newLikeCount,
    );

    final previousPost = currentPost;

    state = state.copyWith(post: updatedPost);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!_mounted) return;

      final finalPost = state.post;
      if (finalPost == null) return;

      try {
        await ref
            .read(toggleLikeUseCaseProvider)
            .call(finalPost.postId, user.uid, wasLiked);

        // 좋아요를 누른 경우에만 알림 전송
        if (!wasLiked) {
          await ref
              .read(createNotificationUseCaseProvider)
              .call(
                userId: finalPost.userId,
                type: 'like',
                message: '${user.nickname}님이 좋아요를 눌렀습니다.',
                senderId: user.uid,
                senderNickname: user.nickname,
                senderProfileImage: user.profileImage ?? '',
                targetId: finalPost.postId,
              );
        }
      } catch (e) {
        debugPrint('좋아요 실패: $e');
        if (!_mounted) return;
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
      if (!_mounted) return;
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
      if (!_mounted) return;
      state = state.copyWith(error: '댓글 삭제 실패');
    }
  }

  void removeComment(String targetId) {
    final filteredComments = state.comments
        .where((c) => c.commentId != targetId && c.userId != targetId)
        .toList();
    state = state.copyWith(comments: filteredComments);
  }
}

// autoDispose: 화면 이탈 시 StreamSubscription 등 리소스 즉시 해제
final detailViewModelProvider = NotifierProvider.autoDispose
    .family<DetailViewModel, DetailState, String>(
      (arg) => DetailViewModel()..postId = arg,
    );
