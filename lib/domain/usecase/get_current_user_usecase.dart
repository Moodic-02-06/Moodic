import '../entity/user_entity.dart';
import '../repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  UserEntity? get currentUser => repository.currentUser;

  Stream<UserEntity?> get authStateChanges => repository.authStateChanges;
}
