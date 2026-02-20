import '../entity/block.dart';
import '../repository/block_repository.dart';

class GetBlocksUseCase {
  final BlockRepository _repository;

  GetBlocksUseCase(this._repository);

  Future<List<Block>> execute(String userId) async {
    return await _repository.getBlocks(userId);
  }
}
