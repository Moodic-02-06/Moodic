import 'package:flutter_moodic/domain/entity/user_entity.dart';

// 인증 repository
abstract class AuthRepository {
  //구글 로그인
  Future<String?> signInWithGoogle();

  //카카오 로그인
  Future<String?> signInWithKakao();

  //로그아웃
  Future<void> signOut();

  UserEntity? get currentUser;

  Stream<UserEntity?> get authStateChanges;

  // ✅ 추가: 유저가 서버(DB)에 실제로 존재하는지 확인
  Future<bool> checkUserExists(String uid);

  // 계정 삭제 (회원탈퇴)
  Future<void> deleteAccount();
}
