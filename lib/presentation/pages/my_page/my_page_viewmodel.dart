import 'dart:async';

import 'package:flutter_moodic/domain/usecase/check_follow_status_usecase.dart';
import 'package:flutter_moodic/domain/usecase/follow_user_usecase.dart';
import 'package:flutter_moodic/domain/usecase/unfollow_user_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/domain/usecase/fetch_user_posts_usecase.dart';
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

  final bool isUploading;
  final File? optimisticProfileImage;

  final int postCount;
  final int followerCount;
  final int followingCount;

  final bool isFollowing;

  MyPageState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    required this.nickname,
    this.bio,
    this.profileimage,
    this.isUploading = false,
    this.optimisticProfileImage,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
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
    int? postCount,
    int? followerCount,
    int? followingCount,
    bool? isFollowing,
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
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

/// 마이페이지 피드 목록 Provider (Family로 변경하여 authorId 받음)
final myPageFamilyFeedsProvider = StreamProvider.family
    .autoDispose<List<Post>, String>((ref, authorId) {
      final currentUid = ref.watch(
        userProvider.select((value) => value.value?.uid),
      );

      final repository = ref.read(postRepositoryProvider);
      final fetchUserPostsUseCase = FetchUserPostsUseCase(repository);

      return fetchUserPostsUseCase.call(authorId, currentUserId: currentUid);
    });

/// Riverpod 3.x: Notifier.family 패턴
/// arg = 타겟 유저 ID (null이면 "나")
class MyPageViewModel extends Notifier<MyPageState> {
  /// feedsStreamProvider 스트림을 직접 구독하는 subscription
  StreamSubscription<List<Post>>? _feedsSubscription;
  bool _mounted = true;
  String? _arg; // factory에서 주입되는 인자

  // factory에서 arg를 inject할 때 사용
  MyPageViewModel setArg(String? arg) {
    _arg = arg;
    return this;
  }

  @override
  MyPageState build() {
    _mounted = true; // re-build 시 반드시 초기화
    ref.onDispose(() {
      _mounted = false;
      _feedsSubscription?.cancel();
      _feedsSubscription = null; // 재진입 시 null 체크를 위해 리셋
    });

    // "나" 프로필: userProvider 변경 시 닉네임·프로필 동기화 + 피드 연결 보장
    if (_arg == null) {
      ref.listen<AsyncValue<UserEntity?>>(userProvider, (previous, next) {
        final user = next.value;
        if (user == null || !_mounted) return;

        // 유저 정보 동기화
        state = state.copyWith(
          nickname: user.nickname,
          bio: user.bio,
          profileimage: user.profileImage,
          postCount: user.postCount,
          followerCount: user.followerCount,
          followingCount: user.followingCount,
        );

        // 피드 구독이 아직 안 되어 있으면 (재진입 시 userProvider가 늘리 완료된 경우) 재시도
        if (_feedsSubscription == null) {
          Future.microtask(() => _subscribeFeed(user.uid));
        }
      });
    }

    // 비동기 초기화 (microtask로 지연 → build() 완료 후 state 접근 보장)
    Future.microtask(() => _load(_arg));

    return MyPageState(nickname: '', feeds: [], isLoading: true);
  }

  Future<void> _load(String? userId) async {
    if (!_mounted) return;

    final currentUserState = ref.read(userProvider);

    // userProvider가 아직 로딩 중이면 대기 (로딩 정왕이 아니라 ref.listen이 콜백함)
    if (currentUserState.isLoading) {
      // build()에서 ref.listen이 인자=null일 때 콜백하므로 여기서 기다림
      // 인자가 있는 경우(👤 🤵‍♂️ 타인 프로필)는 역주음 외부로 빠짘 편
      if (userId != null) {
        // 타인 프로필: 대기하는 것보다 간단히 잠시 지연 후 재시도
        await Future.delayed(const Duration(milliseconds: 300));
        if (_mounted) await _load(userId);
      }
      // 나 프로필: ref.listen이 userProvider 완료 시 콜백하므로 여기서는 보렬마 없음
      return;
    }

    final myUid = currentUserState.value?.uid;

    // 1. 타겟 유저 결정 (타겟이 없으면 나)
    final userIdToLoad = userId ?? myUid;

    if (userIdToLoad == null) {
      // 로그인 정보가 없음 (userProvider가 완료되었지만 유저가 null)
      if (_mounted) state = state.copyWith(isLoading: false);
      return;
    }

    String? nickname;
    String? bio;
    String? profileImage;
    int postCount = 0;
    int followerCount = 0;
    int followingCount = 0;
    bool isFollowing = false;

    // 2. 유저 정보 가져오기
    if (userId == null || userId == myUid) {
      // "나"인 경우 — userProvider에서 바로 읽기
      final user = currentUserState.value;
      nickname = user?.nickname ?? '닉네임 없음';
      bio = user?.bio;
      profileImage = user?.profileImage;
      postCount = user?.postCount ?? 0;
      followerCount = user?.followerCount ?? 0;
      followingCount = user?.followingCount ?? 0;
    } else {
      // "타인"인 경우 — Repository에서 fetch
      try {
        final repository = ref.read(userRepositoryProvider);
        final userEntity = await repository.getUser(userIdToLoad);

        if (!_mounted) return;

        nickname = userEntity?.nickname ?? '알 수 없는 사용자';
        bio = userEntity?.bio;
        profileImage = userEntity?.profileImage;
        postCount = userEntity?.postCount ?? 0;
        followerCount = userEntity?.followerCount ?? 0;
        followingCount = userEntity?.followingCount ?? 0;

        // 팔로우 여부 확인
        if (myUid != null) {
          isFollowing = await CheckFollowStatusUseCase(
            ref.read(userRepositoryProvider),
          ).call(myUid, userIdToLoad);
        }
      } catch (e) {
        nickname = '유저 로드 실패';
      }
    }

    if (!_mounted) return;

    state = state.copyWith(
      nickname: nickname,
      bio: bio,
      profileimage: profileImage,
      postCount: postCount,
      followerCount: followerCount,
      followingCount: followingCount,
      isFollowing: isFollowing,
      isLoading: true, // 피드 로딩 대기 중
    );

    // 3. 피드 스트림 직접 구독
    // async 함수 내부에서는 ref.listen 사용 불가 → StreamSubscription으로 처리
    await _subscribeFeed(userIdToLoad);
  }

  Future<void> _subscribeFeed(String userIdToLoad) async {
    await _feedsSubscription?.cancel();

    final repository = ref.read(postRepositoryProvider);
    final currentUserId = ref.read(userProvider.select((v) => v.value?.uid));
    final fetchUserPostsUseCase = FetchUserPostsUseCase(repository);
    final stream = fetchUserPostsUseCase.call(
      userIdToLoad,
      currentUserId: currentUserId,
    );

    _feedsSubscription = stream.listen(
      (feeds) {
        if (_mounted) {
          // feeds 스트림에서 실시간으로 반영되므로 postCount도 함께 갱신
          state = state.copyWith(
            feeds: feeds,
            isLoading: false,
            postCount: feeds.length,
          );
        }
      },
      onError: (err) {
        debugPrint('MyPage Feed Error: $err');
        if (_mounted) {
          state = state.copyWith(
            errorMessage: err.toString(),
            isLoading: false,
          );
        }
      },
    );
  }

  /// 팔로우/언팔로우 토글
  Future<void> toggleFollow() async {
    final myUid = ref.read(userProvider).value?.uid;
    final targetUid = _arg; // Riverpod 3.x: factory에서 주입된 _arg 필드 사용

    if (myUid == null || targetUid == null || myUid == targetUid) return;

    final repository = ref.read(userRepositoryProvider);
    final isCurrentlyFollowing = state.isFollowing;

    // 낙관적 업데이트
    if (_mounted) {
      state = state.copyWith(
        isFollowing: !isCurrentlyFollowing,
        followerCount: state.followerCount + (isCurrentlyFollowing ? -1 : 1),
      );
    }

    try {
      if (isCurrentlyFollowing) {
        await UnfollowUserUseCase(repository).call(myUid, targetUid);
      } else {
        final currentUser = ref.read(userProvider).value;
        await FollowUserUseCase(repository).call(
          myUid,
          targetUid,
          senderNickname: currentUser?.nickname ?? '',
          senderProfileImage: currentUser?.profileImage ?? '',
        );
      }
    } catch (e) {
      // 실패 시 롤백
      if (_mounted) {
        state = state.copyWith(
          isFollowing: isCurrentlyFollowing,
          followerCount: state.followerCount + (isCurrentlyFollowing ? 1 : -1),
          errorMessage: '팔로우 처리 중 오류가 발생했습니다.',
        );
      }
    }
  }

  /// 프로필 저장 (낙관적 업데이트 적용) - "나"일 때만 호출됨
  Future<void> saveProfile({
    required File? imageFile,
    required String nickname,
    required String bio,
    required bool isNotificationEnabled,
    required UserEntity currentUser,
  }) async {
    if (_mounted) {
      state = state.copyWith(
        isUploading: imageFile != null,
        optimisticProfileImage: imageFile,
        nickname: nickname,
        bio: bio,
      );
    }

    try {
      String? imageUrl;

      if (imageFile != null) {
        imageUrl = await ref
            .read(userRepositoryProvider)
            .uploadProfileImage(imageFile.path, currentUser.uid);
      }

      final updatedUser = currentUser.copyWith(
        nickname: nickname,
        bio: bio,
        profileImage: imageUrl ?? currentUser.profileImage,
        isNotificationEnabled: isNotificationEnabled,
      );

      await ref.read(userRepositoryProvider).saveUser(updatedUser);

      if (_mounted) {
        state = state.copyWith(
          isUploading: false,
          optimisticProfileImage: null,
          profileimage: updatedUser.profileImage,
        );
      }
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: '프로필 저장 실패: $e',
        );
      }
    }
  }
}

/// 월별 감정 통계 Provider
final monthlyMoodsProvider = FutureProvider.family<Map<MoodType, int>, String>((
  ref,
  userId,
) async {
  final repository = ref.read(postRepositoryProvider);
  final now = DateTime.now();
  final posts = await repository.fetchPostsByMonth(userId, now.year, now.month);

  final Map<MoodType, int> counts = {for (var mood in MoodType.values) mood: 0};

  for (var post in posts) {
    try {
      final moodEnum = MoodType.values.firstWhere(
        (m) => m.label == post.mood || m.name == post.mood,
        orElse: () => MoodType.happy,
      );
      counts[moodEnum] = (counts[moodEnum] ?? 0) + 1;
    } catch (_) {}
  }

  return counts;
});

// autoDispose: 화면 이탈 시 provider가 dispose되어
// 재진입 시 build()가 다시 실행되므로 데이터가 새로고침
final myPageViewModelProvider = NotifierProvider.autoDispose
    .family<MyPageViewModel, MyPageState, String?>(
      (arg) => MyPageViewModel().setArg(arg),
    );
