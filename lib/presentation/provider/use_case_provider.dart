import 'package:flutter_moodic/domain/usecase/toggle_like_usecase.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  return ToggleLikeUseCase(ref.read(postRepositoryProvider));
});
