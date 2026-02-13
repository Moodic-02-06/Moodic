import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';

class TempProfileState {
  final String nickname;
  final String? profileImage; // 로컬 경로
  final String bio;
  final bool isLoading;
  final String? error;

  const TempProfileState({
    this.nickname = '',
    this.profileImage,
    this.bio = '',
    this.isLoading = false,
    this.error,
  });

  TempProfileState copyWith({
    String? nickname,
    String? profileImage,
    String? bio,
    bool? isLoading,
    String? error,
  }) {
    return TempProfileState(
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TempProfileViewModel extends Notifier<TempProfileState> {
  final ImagePicker _picker = ImagePicker();

  @override
  TempProfileState build() {
    final socialUser = FirebaseAuth.instance.currentUser;

    return TempProfileState(
      nickname: socialUser?.displayName ?? '',
      profileImage: socialUser?.photoURL,
    );
  }

  void onNicknameChanged(String name) => state = state.copyWith(nickname: name);

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image != null) {
        state = state.copyWith(profileImage: image.path);
      }
    } catch (e) {
      state = state.copyWith(error: '이미지를 선택하는 중 오류가 발생했습니다.');
    }
  }

  Future<bool> completeProfile(String uid) async {
    if (state.nickname.trim().isEmpty) {
      state = state.copyWith(error: '닉네임을 입력해주세요.');
      return false;
    }

    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true, error: null);

    try {
      String? firebaseImageUrl = state.profileImage;

      // 1. 이미지 업로드 (Write 패턴)
      if (state.profileImage != null &&
          !state.profileImage!.startsWith('http')) {
        firebaseImageUrl = await ref
            .read(userRepositoryProvider)
            .uploadProfileImage(state.profileImage!, uid);
      }

      // 2. UserEntity 생성
      final user = UserEntity(
        uid: uid,
        nickname: state.nickname.trim(),
        profileImage: firebaseImageUrl,
        bio: state.bio.trim(),
        isFirst: false,
      );

      // 3. DB 저장
      await ref.read(userRepositoryProvider).saveUser(user);

      // 4. 전역 유저 상태 새로고침
      ref.invalidate(userProvider);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '저장 실패: $e');
      return false;
    }
  }
}

final tempProfileViewModelProvider =
    NotifierProvider<TempProfileViewModel, TempProfileState>(
      TempProfileViewModel.new,
    );
