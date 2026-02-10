import 'package:flutter_moodic/data/data_source/auth_remote_data_source.dart';
import 'package:flutter_moodic/domain/repository/auth_repository.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<String?> signInWithGoogle() async {
    // 소스에게 시키고 결과(uid)만 받아서 넘겨줌
    return await _dataSource.signInWithGoogle();
  }

  @override
  Future<String?> signInWithKakao() async {
    return await _dataSource.signInWithKakao();
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  UserEntity? get currentUser => _dataSource.currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = AuthRemoteDataSource();
  return AuthRepositoryImpl(dataSource);
});
