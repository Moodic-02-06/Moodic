import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/post_dto.dart';
import '../dto/comment_dto.dart';

class FirestorePostDataSource {
  final FirebaseFirestore _firestore;

  FirestorePostDataSource(this._firestore);

  /// 최신 피드 가져오기
  Future<List<PostDto>> fetchFeeds({
    int limit = 20,
    String? currentUserId,
  }) async {
    final feedQuery = await _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final feedIdList = feedQuery.docs.map((doc) => doc.id).toList();

    final likedFeedIdSet = (currentUserId != null && feedIdList.isNotEmpty)
        ? (await _firestore
                  .collection('likes')
                  .where('userId', isEqualTo: currentUserId)
                  .where('feedId', whereIn: feedIdList)
                  .get())
              .docs
              .map((doc) => doc['feedId'] as String)
              .toSet()
        : <String>{};

    return feedQuery.docs
        .map(
          (doc) => PostDto.fromJson(
            doc.data(),
            doc.id,
            isLikedByMe: likedFeedIdSet.contains(doc.id),
          ),
        )
        .toList();
  }

  /// 특정 포스트 가져오기
  Future<PostDto> fetchPostById(String postId, String? currentUserId) async {
    final doc = await _firestore.collection('feeds').doc(postId).get();

    final likedFeedIdSet = (currentUserId != null)
        ? (await _firestore
                  .collection('likes')
                  .where('userId', isEqualTo: currentUserId)
                  .where('feedId', isEqualTo: postId)
                  .get())
              .docs
              .map((doc) => doc['feedId'] as String)
              .toSet()
        : <String>{};

    return PostDto.fromJson(
      doc.data()!,
      doc.id,
      isLikedByMe: likedFeedIdSet.contains(doc.id),
    );
  }

  /// 좋아요 토글
  Future<void> toggleLike(
    String postId,
    String userId,
    bool isCurrentlyLiked,
  ) async {
    final likeDocRef = _firestore.collection('likes').doc('${postId}_$userId');
    final feedDocRef = _firestore.collection('feeds').doc(postId);

    if (isCurrentlyLiked) {
      await likeDocRef.delete();
      await feedDocRef.update({'likeCount': FieldValue.increment(-1)});
    } else {
      await likeDocRef.set({
        'feedId': postId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await feedDocRef.update({'likeCount': FieldValue.increment(1)});
    }
  }

  /// 댓글 조회
  Future<List<CommentDto>> fetchComments(String postId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('feedId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => CommentDto.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// 댓글 추가
  Future<void> addComment(String postId, String userId, String content) async {
    final commentRef = _firestore.collection('comments').doc();
    await commentRef.set({
      'feedId': postId,
      'userId': userId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('feeds').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  /// 포스트 작성
  Future<void> createPost(PostDto dto) async {
    final docRef = _firestore.collection('feeds').doc(dto.postId);
    await docRef.set(dto.toJson());
  }

  /// 포스트 수정
  Future<void> updatePost(PostDto dto) async {
    final docRef = _firestore.collection('feeds').doc(dto.postId);
    await docRef.update(dto.toJson());
  }

  /// 포스트 삭제
  Future<void> deletePost(String postId) async {
    await _firestore.collection('feeds').doc(postId).delete();
  }
}
