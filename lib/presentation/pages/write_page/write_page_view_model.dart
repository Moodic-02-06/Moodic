import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';
import 'package:flutter_moodic/presentation/pages/write_page/selected_music_provider.dart';
import 'package:flutter_moodic/presentation/provider/write_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/post.dart';

class WriteState {
  final String content;
  final MoodType mood;
  final List<String> imageUrls;

  WriteState({
    required this.content,
    required this.mood,
    required this.imageUrls,
  });

  WriteState copyWith({
    String? content,
    MoodType? mood,
    List<String>? imageUrls,
  }) {
    return WriteState(
      content: content ?? this.content,
      mood: mood ?? this.mood,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

class WriteViewModel extends Notifier<WriteState> {
  @override
  WriteState build() {
    return WriteState(content: '', mood: MoodType.happy, imageUrls: []);
  }

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

  void removeImage(int index) {
    if (index < 0 || index >= state.imageUrls.length) return;

    final updatedList = List<String>.from(state.imageUrls)..removeAt(index);

    state = state.copyWith(imageUrls: updatedList);
  }

  Future<void> createPost(
    String userId,
    String userName,
    String userImageUrl,
  ) async {
    // 1. 데이터 검증 (필수 항목 체크)
    final selectedMusic = ref.read(selectedMusicProvider);
    if (selectedMusic == null) throw Exception('음악을 선택해주세요.');
    if (state.content.trim().isEmpty) throw Exception('내용을 입력해주세요.');

    try {
      // 2. 이미지 업로드 (로컬 경로 -> Firebase Storage URL)
      List<String> firebaseImageUrls = [];

      if (state.imageUrls.isNotEmpty) {
        // 2. 이미지 업로드 (UseCase 실행)
        firebaseImageUrls = await ref.read(uploadImagesUseCaseProvider)(
          userId,
          state.imageUrls,
        );
      }

      //  비동기 작업(Storage 업로드) 이후에 ViewModel이 해제되었는지 확인
      if (!ref.mounted) return;

      // 3. Post 객체 생성
      final post = Post(
        postId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        userImageUrl: userImageUrl,
        mood: state.mood.label,
        content: state.content,
        music: selectedMusic,
        imageUrls: firebaseImageUrls,
        likeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 4. DB 저장 (UseCase 실행)
      await ref.read(createPostUseCaseProvider)(post);

      if (!ref.mounted) return;

      ref.invalidate(homeViewModelProvider);

      ref.read(selectedMusicProvider.notifier).clear();
      state = build();

      debugPrint("글 작성이 완료되었습니다!");
    } catch (e) {
      if (!ref.mounted) return;

      debugPrint("글 작성 중 에러 발생: $e");
      rethrow;
    }
  }
}

final writeViewModelProvider =
    NotifierProvider.autoDispose<WriteViewModel, WriteState>(
      WriteViewModel.new,
    );
