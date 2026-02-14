import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/domain/usecase/fetch_feeds_usecase.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'dart:io';

class MyPageState {
  final String nickname;
  final String? bio;
  final String? profileimage;
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;

  // 낙관적 업데이트를 위한 필드 추가
  final bool isUploading;
  final File? optimisticProfileImage;

  MyPageState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    required this.nickname,
    this.bio,
    this.profileimage,
    this.isUploading = false,
    this.optimisticProfileImage,
  });

  MyPageState copyWith({
    String? nickname,
    String? bio,
    String? profileimage,
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
    bool? isUploading,
    File? optimisticProfileImage,
  }) {
    return MyPageState(
      nickname: nickname ?? this.nickname,
      bio: bio ?? this.bio,
      profileimage: profileimage ?? this.profileimage,
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploading: isUploading ?? this.isUploading,
      optimisticProfileImage:
          optimisticProfileImage ?? this.optimisticProfileImage,
    );
  }
}

class MyPageViewModel extends AsyncNotifier<MyPageState> {
  @override
  Future<MyPageState> build() async {
    final userState = ref.watch(userProvider);
    final repository = ref.read(postRepositoryProvider);
    final fetchFeedsUseCase = FetchFeedsUseCase(repository);
    var fetchedFeeds = await fetchFeedsUseCase.call(
      limit: 50,
      userId: userState.value?.uid,
    );

    // 기존의 낙관적 상태가 있다면 유지하고 싶을 수 있지만,
    // userProvider가 갱신되면 build가 다시 호출되므로
    // 최신 userState 값을 우선으로 하되, 업로드 중이 아닐 때만 덮어쓰도록 로직을 구성할 수도 있음.
    // 하지만 여기서는 심플하게 userState를 따르도록 하고,
    // saveProfile에서 state를 갱신할 때 userProvider 갱신으로 인한 리빌드를 고려해야 함.
    // userProvider Stream이 갱신되면 build가 다시 호출되어 state가 초기화될 수 있음.
    // 다만 AsyncNotifier의 state는 build 결과로 덮어씌워짐.

    // 업로드 중(isUploading=true)일 때는 기존 상태를 유지하는 것이 좋을 수 있으나,
    // build는 userProvider가 변경될 때마다 호출됨.
    // 업로드가 완료되어 userProvider가 갱신되면 isUploading을 false로 풀어줘야 함.

    return MyPageState(
      nickname: userState.value?.nickname ?? "닉네임을 알수없음",
      bio: userState.value?.bio,
      profileimage: userState.value?.profileImage,
      feeds: fetchedFeeds,
    );
  }

  /// 프로필 저장 (낙관적 업데이트 적용)
  Future<void> saveProfile({
    required File? imageFile,
    required String nickname,
    required String bio,
    required UserEntity currentUser,
  }) async {
    // 1. 낙관적 업데이트: UI 즉시 반영
    state = AsyncData(
      state.value!.copyWith(
        isUploading: true,
        optimisticProfileImage: imageFile,
        nickname: nickname,
        bio: bio,
      ),
    );

    try {
      String? imageUrl = currentUser.profileImage;

      // 2. 이미지 업로드 (변경된 경우)
      if (imageFile != null) {
        imageUrl = await ref
            .read(userRepositoryProvider)
            .uploadProfileImage(imageFile.path, currentUser.uid);
      }

      // 3. 유저 정보 업데이트
      final updatedUser = currentUser.copyWith(
        nickname: nickname,
        bio: bio,
        profileImage: imageUrl,
      );

      await ref.read(userRepositoryProvider).updateUser(updatedUser);

      // 성공 시: userProvider가 자동으로 최신 데이터를 가져오므로
      // 별도의 state 갱신 없이 build가 다시 호출되어 isUploading이 false가 된 상태로 돌아올 것임.
      // 하지만 명시적으로 업로드 완료 상태를 잡아주고 싶다면 아래와 같이 할 수 있음.
      // 다만 build가 비동기로 호출될 때 타이밍 이슈가 있을 수 있으니 주의.

      // 여기서는 성공했음을 가정하고, userProvider가 갱신되기를 기다리는 자연스러운 흐름을 따름.
    } catch (e) {
      // 실패 시: 에러 메시지 설정 및 로딩 상태 해제, 원래 값으로 복구는 복잡하므로 에러만 표시
      if (state.hasValue) {
        state = AsyncData(
          state.value!.copyWith(
            isUploading: false,
            errorMessage: "프로필 저장 실패: $e",
          ),
        );
      }
    }
  }
}

/// 월별 감정 통계 Provider (Family로 userId 받음)
final monthlyMoodsProvider = FutureProvider.family<Map<MoodType, int>, String>((
  ref,
  userId,
) async {
  final repository = ref.read(postRepositoryProvider);
  final now = DateTime.now();
  final posts = await repository.fetchPostsByMonth(userId, now.year, now.month);

  final Map<MoodType, int> counts = {};

  // 초기화
  for (var mood in MoodType.values) {
    counts[mood] = 0;
  }

  // 카운팅
  for (var post in posts) {
    try {
      final moodEnum = MoodType.values.firstWhere(
        (m) => m.label == post.mood || m.name == post.mood,
        orElse: () => MoodType.happy,
      );
      counts[moodEnum] = (counts[moodEnum] ?? 0) + 1;
    } catch (e) {
      // ignore
    }
  }

  return counts;
});

final myPageViewModelProvider =
    AsyncNotifierProvider<MyPageViewModel, MyPageState>(() {
      return MyPageViewModel();
    });
