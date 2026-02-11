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

  return useCase.authStateChanges.asyncMap((user) async {
    // 1. 로그아웃 상태일 때
    if (user == null) {
      print('<<<< 🔒 유저 로그아웃 상태 >>>>');
      return null;
    }

    try {
      // 2. 서버에 실제로 계정이 존재하는지 체크 (계정 삭제 대응)
      final exists = await ref
          .read(authRepositoryProvider)
          .checkUserExists(user.uid);

      if (!exists) {
        print('⚠️ 계정 삭제 감지: 강제 로그아웃 진행');
        await ref.read(authRepositoryProvider).signOut();
        return null;
      }

      // 3. 정상 로그인 상태일 때 로그 출력
      print('<<<< 🔓 유저 로그인 상태 유지 >>>>');
      print('UID: ${user.uid}');
      print('닉네임: ${user.nickname}');
      print('처음인가요?: ${user.isFirst}');
      print('<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>');

      return user;
    } catch (e) {
      print('❌ 유저 인증 확인 중 에러: $e');
      return null;
    }
  });
});
