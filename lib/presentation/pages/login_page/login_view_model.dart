import 'package:flutter/material.dart';
import 'package:flutter_moodic/data/repository/auth_repository_impl.dart';
import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel extends Notifier<UserEntity?> {
  // 1. 초기 상태 설정
  @override
  UserEntity? build() {
    return null;
  }

  // 2. 로그인 함수 (클래스 안에 포함)
  Future<void> loginWithGoogle() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final String? uid = await authRepo.signInWithGoogle();

      if (uid == null) return; // 취소 시 종료

      final userRepo = ref.read(userRepositoryProvider);
      final existingUser = await userRepo.getUser(uid);

      if (existingUser == null) {
        // 신규 유저 저장
        final newUser = UserEntity(uid: uid);
        await userRepo.saveUser(newUser);
        state = newUser; // 상태 업데이트
      } else {
        // 기존 유저 상태 저장
        state = existingUser;
      }
    } catch (e) {
      debugPrint("로그인 에러: $e");
    }
  }

  Future<void> loginWithkakao() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final String? uid = await authRepo.signInWithKakao();

      if (uid == null) return; // 취소 시 종료

      final userRepo = ref.read(userRepositoryProvider);
      final existingUser = await userRepo.getUser(uid);

      if (existingUser == null) {
        // 신규 유저 저장
        final newUser = UserEntity(uid: uid);
        await userRepo.saveUser(newUser);
        state = newUser; // 상태 업데이트
      } else {
        // 기존 유저 상태 저장
        state = existingUser;
      }
    } catch (e) {
      debugPrint("로그인 에러: $e");
    }
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, UserEntity?>(
  () {
    return LoginViewModel();
  },
);
