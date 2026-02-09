//로그인 해라
import 'package:flutter_moodic/domain/repository/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<String?> execute() async {
    return await repository.signInWithGoogle();
  }

  Future<String?> executes() async {
    return await repository.signInWithKakao();
  }
}
