import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';
import 'package:flutter_moodic/presentation/pages/write_page/selected_music_provider.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/write_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';

class WriteState {
  final String? postId;
  final String content;
  final MoodType mood;
  final List<String> imageUrls;
  final bool isLoading;

  WriteState({
    this.postId,
    required this.content,
    required this.mood,
    required this.imageUrls,
    this.isLoading = false,
  });

  WriteState copyWith({
    String? postId,
    String? content,
    MoodType? mood,
    List<String>? imageUrls,
    bool? isLoading,
  }) {
    return WriteState(
      postId: postId ?? this.postId,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      imageUrls: imageUrls ?? this.imageUrls,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WriteViewModel extends Notifier<WriteState> {
  Post? _originPost;

  bool _mounted = true;

  @override
  WriteState build() {
    ref.onDispose(() {
      _mounted = false;
    });
    return WriteState(
      postId: null,
      content: '',
      mood: MoodType.happy,
      imageUrls: [],
    );
  }

  // ... (setContent, setMood, addImages, _uploadImagesIfNeeded, initEdit, initNewPost, removeImage methods are unchanged)

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void setMood(MoodType mood) {
    state = state.copyWith(mood: mood);
  }

  void addImages(List<String> newPaths) {
    final updatedImages = [...state.imageUrls, ...newPaths];

    // 최대 10장까지만 유지하고 리스트화
    state = state.copyWith(imageUrls: updatedImages.take(10).toList());
  }

  Future<List<String>> _uploadImagesIfNeeded(String userId) async {
    // 새 이미지가 하나라도 있으면 업로드
    if (state.imageUrls.any((e) => e.startsWith('/'))) {
      return await ref.read(uploadImagesUseCaseProvider)(
        userId,
        state.imageUrls,
      );
    }

    // 전부 기존 URL이면 그대로
    return state.imageUrls;
  }

  void initEdit(Post post) {
    _originPost = post;

    ref.read(selectedMusicProvider.notifier).set(post.music);

    state = WriteState(
      postId: post.postId,
      content: post.content,
      mood: MoodType.fromLabel(post.mood),
      imageUrls: post.imageUrls,
    );
  }

  void initNewPost() {
    _originPost = null;
    ref.read(selectedMusicProvider.notifier).clear();
    state = build();
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.imageUrls.length) return;

    final updatedList = List<String>.from(state.imageUrls)..removeAt(index);

    state = state.copyWith(imageUrls: updatedList);
  }

  Future<void> createPost(
    String userId,
    String nickname,
    String profileImage,
  ) async {
    // 데이터 검증 (필수 항목 체크)
    final selectedMusic = ref.read(selectedMusicProvider);
    if (selectedMusic == null) throw Exception('음악을 선택해주세요.');
    if (state.content.trim().isEmpty) throw Exception('내용을 입력해주세요.');

    // 이미 로딩 중이면 중복 실행 방지
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final imageUrls = await _uploadImagesIfNeeded(userId);

      if (!_mounted) return;

      // Post 객체 생성
      final post = Post(
        postId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userNickname: nickname,
        userImageUrl: profileImage,
        mood: state.mood.label,
        content: state.content,
        music: selectedMusic,
        imageUrls: imageUrls,
        likeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // DB 저장 (UseCase 실행)
      await ref.read(createPostUseCaseProvider)(post);

      if (!_mounted) return;

      // 직접 로드 호출
      ref.read(homeViewModelProvider.notifier).loadFeeds();

      // 마이페이지 감정 그래프 갱신
      ref.invalidate(monthlyMoodsProvider(userId));
      // 마이페이지 피드 목록 갱신
      ref.invalidate(myPageFamilyFeedsProvider(userId));

      ref.read(selectedMusicProvider.notifier).clear();
      // 작업 완료 후 초기화 (isLoading도 false로 돌아감)
      state = build();

      debugPrint("글 작성이 완료되었습니다!");
    } catch (e) {
      if (!_mounted) return;

      state = state.copyWith(isLoading: false);

      debugPrint("글 작성 중 에러 발생: $e");
      rethrow;
    }
  }

  Future<void> updatePost(
    String userId,
    String nickname,
    String profileImage,
  ) async {
    final selectedMusic = ref.read(selectedMusicProvider);

    if (selectedMusic == null) throw Exception('음악을 선택해주세요.');
    if (state.content.trim().isEmpty) throw Exception('내용을 입력해주세요.');
    if (state.postId == null) throw Exception('수정할 게시글을 찾을 수 없습니다.');
    if (_originPost == null) {
      throw Exception('원본 게시글 정보가 없습니다.');
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final imageUrls = await _uploadImagesIfNeeded(userId);

      if (!_mounted) return;

      final post = Post(
        postId: state.postId!,
        userId: userId,
        userNickname: nickname,
        userImageUrl: profileImage,
        mood: state.mood.label,
        content: state.content,
        music: selectedMusic,
        imageUrls: imageUrls,
        likeCount: _originPost!.likeCount,
        commentCount: _originPost!.commentCount,
        isLikedByMe: _originPost!.isLikedByMe,
        createdAt: _originPost!.createdAt,
        updatedAt: DateTime.now(),
      );

      await ref.read(updatePostUseCaseProvider).call(post);

      if (!_mounted) return;

      ref.read(homeViewModelProvider.notifier).loadFeeds();
      // 마이페이지 피드 목록 갱신
      ref.invalidate(myPageFamilyFeedsProvider(userId));

      state = build();
      _originPost = null;

      debugPrint('글 수정 완료');
    } catch (e) {
      if (!_mounted) return;

      state = state.copyWith(isLoading: false);

      debugPrint('글 수정 실패: $e');
      rethrow;
    }
  }

  bool get isChanged {
    if (_originPost == null) {
      // 새 글
      return state.content.isNotEmpty ||
          state.imageUrls.isNotEmpty ||
          state.mood != MoodType.happy;
    }

    // 수정 글
    return state.content != _originPost!.content ||
        state.imageUrls.join() != _originPost!.imageUrls.join() ||
        state.mood != MoodType.fromLabel(_originPost!.mood);
  }
}

final writeViewModelProvider = NotifierProvider<WriteViewModel, WriteState>(
  WriteViewModel.new,
);
