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
  return useCase.authStateChanges;
});
