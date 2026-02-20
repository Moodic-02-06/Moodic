import '../entity/block.dart';

abstract class BlockRepository {
  Future<void> blockTarget(String userId, String targetId, String targetType);
  Future<List<String>> getBlockedIds(String userId);
  Future<void> unblockTarget(String userId, String targetId);
  Future<List<Block>> getBlocks(String userId);
}
