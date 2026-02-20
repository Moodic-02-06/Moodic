import '../../domain/entity/block.dart';
import '../../domain/repository/block_repository.dart';
import '../data_source/remote/block_remote_data_source.dart';

class BlockRepositoryImpl implements BlockRepository {
  final BlockRemoteDataSource _dataSource;

  BlockRepositoryImpl(this._dataSource);

  @override
  Future<void> blockTarget(
    String userId,
    String targetId,
    String targetType,
  ) async {
    await _dataSource.blockTarget(userId, targetId, targetType);
  }

  @override
  Future<List<String>> getBlockedIds(String userId) async {
    return await _dataSource.getBlockedIds(userId);
  }

  @override
  Future<void> unblockTarget(String userId, String targetId) async {
    await _dataSource.unblockTarget(userId, targetId);
  }

  @override
  Future<List<Block>> getBlocks(String userId) async {
    return await _dataSource.getBlocks(userId);
  }
}
