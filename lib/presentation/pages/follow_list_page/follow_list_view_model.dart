import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/domain/usecase/follow_user_usecase.dart';
import 'package:flutter_moodic/domain/usecase/unfollow_user_usecase.dart';
import 'package:flutter_moodic/domain/usecase/get_followers_usecase.dart';
import 'package:flutter_moodic/domain/usecase/get_following_usecase.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';

class FollowListState {
  final List<UserEntity> followers;
  final List<UserEntity> following;
  final Set<String> myFollowingIds; // 내가 팔로우하는 사람들의 ID 목록 (버튼 상태용)
  final bool isLoading;

  FollowListState({
    this.followers = const [],
    this.following = const [],
    this.myFollowingIds = const {},
    this.isLoading = false,
  });

  FollowListState copyWith({
    List<UserEntity>? followers,
    List<UserEntity>? following,
    Set<String>? myFollowingIds,
    bool? isLoading,
  }) {
    return FollowListState(
      followers: followers ?? this.followers,
      following: following ?? this.following,
      myFollowingIds: myFollowingIds ?? this.myFollowingIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Riverpod 3.x: Notifier.family 패턴
/// arg는 provider factory에서 주입되며, _arg 필드로 접근
class FollowListViewModel extends Notifier<FollowListState> {
  late String _arg;

  // factory에서 arg를 inject할 때 사용
  FollowListViewModel setArg(String arg) {
    _arg = arg;
    return this;
  }

  @override
  FollowListState build() {
    _loadData(_arg);
    return FollowListState(isLoading: true);
  }

  Future<void> _loadData(String userId) async {
    final repository = ref.read(userRepositoryProvider);
    final currentUser = ref.read(userProvider).value;

    try {
      // 1. 팔로워 / 팔로잉 ID 목록 가져오기
      final getFollowers = GetFollowersUseCase(repository);
      final getFollowing = GetFollowingUseCase(repository);

      final followerIds = await getFollowers.call(userId);
      final followingIds = await getFollowing.call(userId);

      // 2. UserEntity 리스트로 변환 (Future.wait 사용 병렬 처리)
      final followers = await Future.wait(
        followerIds.map((uid) => repository.getUser(uid)),
      );
      final followings = await Future.wait(
        followingIds.map((uid) => repository.getUser(uid)),
      );

      // 3. 내가 팔로우하는 목록 가져오기 (버튼 상태 확인용)
      Set<String> myFollowingIds = {};
      if (currentUser != null) {
        final myFollowingList = await getFollowing.call(currentUser.uid);
        myFollowingIds = myFollowingList.toSet();
      }

      state = state.copyWith(
        followers: followers.whereType<UserEntity>().toList(),
        following: followings.whereType<UserEntity>().toList(),
        myFollowingIds: myFollowingIds,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 팔로우/언팔로우 토글
  Future<void> toggleFollow(String targetUid) async {
    final currentUser = ref.read(userProvider).value;
    if (currentUser == null) return;

    final repository = ref.read(userRepositoryProvider);
    final isFollowing = state.myFollowingIds.contains(targetUid);

    // 낙관적 업데이트
    final newSet = Set<String>.from(state.myFollowingIds);
    if (isFollowing) {
      newSet.remove(targetUid);
    } else {
      newSet.add(targetUid);
    }
    state = state.copyWith(myFollowingIds: newSet);

    try {
      if (isFollowing) {
        await UnfollowUserUseCase(repository).call(currentUser.uid, targetUid);
      } else {
        await FollowUserUseCase(repository).call(currentUser.uid, targetUid);
      }
    } catch (e) {
      // 롤백
      state = state.copyWith(
        myFollowingIds: isFollowing
            ? (newSet..add(targetUid))
            : (newSet..remove(targetUid)),
      );
    }
  }
}

final followListViewModelProvider = NotifierProvider.autoDispose
    .family<FollowListViewModel, FollowListState, String>(
      (arg) => FollowListViewModel()..setArg(arg),
    );
