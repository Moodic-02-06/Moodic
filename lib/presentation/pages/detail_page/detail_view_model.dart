import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
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
      final post = await ref.read(postRepositoryProvider).fetchPostById(postId);

      final comments = await ref
          .read(postRepositoryProvider)
          .fetchComments(postId);

      state = state.copyWith(post: post, comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
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

      await _load();
    } catch (e) {
      debugPrint('--- addComment 에러 발생: $e');
    }
  }

  Future<void> toggleLike(UserEntity user) async {
    final currentPost = state.post;
    if (currentPost == null) return;

    try {
      await ref
          .read(toggleLikeUseCaseProvider)
          .call(currentPost.postId, user.uid, currentPost.isLikedByMe);

      await _load();
    } catch (e) {
      state = state.copyWith(error: '좋아요 실패: $e');
    }
  }
}

final detailViewModelProvider =
    NotifierProvider.family<DetailViewModel, DetailState, String>(
      DetailViewModel.new,
    );
