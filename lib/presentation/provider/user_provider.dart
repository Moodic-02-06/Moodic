import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/data/repository/auth_repository_impl.dart';
import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/core/service/notification_service.dart';
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

      // exists가 false라면 (문서가 없다면) 신규 유저로 간주
      if (!exists) {
        debugPrint('⚠️ 계정 정보 없음: 신규 회원으로 처리 (isFirst = true)');
        return user.copyWith(isFirst: true);
      }

      // 2. 정상 로그인 정보 출력 (디버깅용)
      _logUserInfo(user);

      // 3. FCM 토큰 발급 및 Firestore 업데이트
      try {
        final fcmToken = await NotificationService().getFcmToken();
        if (fcmToken != null && fcmToken != user.fcmToken) {
          debugPrint('📲 FCM 토큰 저장 중: $fcmToken');

          final userRepo = ref.read(userRepositoryProvider);
          await userRepo.updateFcmToken(user.uid, fcmToken);
        }
      } catch (e) {
        debugPrint('FCM 토큰 업데이트 실패: $e');
      }

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
