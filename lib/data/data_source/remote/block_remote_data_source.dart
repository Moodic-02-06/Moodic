import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entity/block.dart';

class BlockRemoteDataSource {
  final FirebaseFirestore _firestore;

  BlockRemoteDataSource(this._firestore);

  Future<void> blockTarget(
    String userId,
    String targetId,
    String targetType,
  ) async {
    final block = Block(
      targetId: targetId,
      targetType: targetType,
      createdAt: DateTime.now(),
    );

    // 차단 대상마다 고유한 ID를 부여하거나, targetId를 문서 ID로 쓸 수 있습니다.
    // 여기서는 targetId 자체를 문서 ID로 써서 중복 차단을 방지합니다.
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .doc(targetId)
        .set(block.toJson());
  }

  Future<List<String>> getBlockedIds(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> unblockTarget(String userId, String targetId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .doc(targetId)
        .delete();
  }

  Future<List<Block>> getBlocks(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Block.fromJson(doc.data()..['targetId'] = doc.id))
        .toList();
  }
}
