import '../repository/block_repository.dart';

class UnblockTargetUseCase {
  final BlockRepository _repository;

  UnblockTargetUseCase(this._repository);

  Future<void> execute(String userId, String targetId) async {
    await _repository.unblockTarget(userId, targetId);
  }
}
