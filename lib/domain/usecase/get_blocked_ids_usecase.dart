import '../repository/block_repository.dart';

class GetBlockedIdsUseCase {
  final BlockRepository _repository;

  GetBlockedIdsUseCase(this._repository);

  Future<List<String>> execute(String userId) async {
    return await _repository.getBlockedIds(userId);
  }
}
