import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/data/repository/auth_repository_impl.dart';
import '../../domain/usecase/get_current_user_usecase.dart';

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final userProvider = StreamProvider<UserEntity?>((ref) {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  final authRepo = ref.read(authRepositoryProvider); // 미리 읽어두기

  return useCase.authStateChanges.asyncMap((user) async {
    if (user == null) {
      debugPrint('<<<< 🔒 유저 로그아웃 상태 >>>>');
      return null;
    }

    try {
      // 1. 실제 존재 여부 검증
      final exists = await authRepo.checkUserExists(user.uid);

      if (!exists) {
        debugPrint('⚠️ 계정 삭제 감지: 세션 종료');
        await authRepo.signOut();
        return null;
      }

      // 2. 정상 로그인 정보 출력 (디버깅용)
      _logUserInfo(user);

      return user;
    } catch (e) {
      debugPrint('❌ 인증 검증 중 오류: $e');
      return null;
    }
  });
});

// 로그 출력 로직만 따로 빼서 깔끔하게 관리
void _logUserInfo(UserEntity user) {
  debugPrint('<<<< 🔓 유저 로그인 상태 유지 >>>>');
  debugPrint(
    '닉네임: ${user.nickname} | 처음인가요: ${user.isFirst} | UID: ${user.uid}',
  );
  debugPrint('<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>');
}
