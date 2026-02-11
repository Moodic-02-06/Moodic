import 'package:flutter_moodic/data/data_source/auth_remote_data_source.dart';
import 'package:flutter_moodic/domain/repository/auth_repository.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  /// 구글 로그인을 실행하여 성공 시 유저의 uid를 반환
  @override
  Future<String?> signInWithGoogle() async {
    return await _dataSource.signInWithGoogle();
  }

  /// 카카오 로그인을 실행하여 성공 시 유저의 uid를 반환
  @override
  Future<String?> signInWithKakao() async {
    return await _dataSource.signInWithKakao();
  }

  /// 앱에서 로그아웃을 수행합니다. (구글/파이어베이스 세션 모두 종료)
  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  /// 현재 로그인되어 있는 유저의 스냅샷 정보를 가져옴
  @override
  UserEntity? get currentUser => _dataSource.currentUser;

  /// 유저의 인증 상태(로그인/로그아웃) 및 Firestore의 유저 데이터를 실시간으로 감시하는 스트림
  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;

  /// 특정 uid를 가진 유저가 Firestore 'user' 컬렉션에 존재하는지 확인
  /// 계정 삭제 여부 판단이나 초기 프로필 설정 여부를 확인할 때 사용
  @override
  Future<bool> checkUserExists(String uid) async {
    return await _dataSource.checkUserExists(uid);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = AuthRemoteDataSource();
  return AuthRepositoryImpl(dataSource);
});
