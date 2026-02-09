// 인증 repository
abstract class AuthRepository {
  //구글 로그인
  Future<String?> signInWithGoogle();

  //카카오 로그인
  Future<String?> signInWithKakao();

  //로그아웃
  Future<void> signOut();
}
