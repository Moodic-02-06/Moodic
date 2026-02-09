import 'package:flutter_moodic/presentation/pages/write_page/post_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/music.dart';

class WriteState {
  final String content;
  final String mood;
  final Music? selectedMusic;
  final List<String> imageUrls;

  WriteState({
    required this.content,
    required this.mood,
    required this.selectedMusic,
    required this.imageUrls,
  });

  WriteState copyWith({
    String? content,
    String? mood,
    Music? selectedMusic,
    List<String>? imageUrls,
  }) {
    return WriteState(
      content: content ?? this.content,
      mood: mood ?? this.mood,
      selectedMusic: selectedMusic ?? this.selectedMusic,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

class WriteViewModel extends Notifier<WriteState> {
  @override
  WriteState build() {
    return WriteState(
      content: '',
      mood: '',
      selectedMusic: null,
      imageUrls: [],
    );
  }

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void setMood(String mood) {
    state = state.copyWith(mood: mood);
  }

  void setMusic(Music music) {
    state = state.copyWith(selectedMusic: music);
  }

  void addImage(String imageUrl) {
    final updatedImages = [...state.imageUrls, imageUrl];
    state = state.copyWith(imageUrls: updatedImages);
  }

  void removeImage(String imageUrl) {
    final updatedImages = state.imageUrls
        .where((url) => url != imageUrl)
        .toList();
    state = state.copyWith(imageUrls: updatedImages);
  }

  Future<void> createPost(
    String userId,
    String userName,
    String userImageUrl,
  ) async {
    final selectedMusic = state.selectedMusic;
    if (selectedMusic == null) {
      throw Exception('음악을 선택해주세요.');
    }

    final post = Post(
      postId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      mood: state.mood,
      content: state.content,
      music: selectedMusic,
      imageUrls: state.imageUrls,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(postRepositoryProvider).createPost(post);
  }
}

final writeViewModelProvider =
    NotifierProvider.autoDispose<WriteViewModel, WriteState>(
      WriteViewModel.new,
    );
