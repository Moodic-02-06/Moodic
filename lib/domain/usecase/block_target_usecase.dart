import '../repository/block_repository.dart';

class BlockTargetUseCase {
  final BlockRepository _repository;

  BlockTargetUseCase(this._repository);

  Future<void> execute(
    String userId,
    String targetId,
    String targetType,
  ) async {
    return await _repository.blockTarget(userId, targetId, targetType);
  }
}
