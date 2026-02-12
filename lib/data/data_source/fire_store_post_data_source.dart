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

    if (!doc.exists || doc.data() == null) {
      throw Exception("해당 포스트를 찾을 수 없습니다.");
    }

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

    await _firestore.runTransaction((transaction) async {
      if (isCurrentlyLiked) {
        transaction.delete(likeDocRef);
        transaction.update(feedDocRef, {'likeCount': FieldValue.increment(-1)});
      } else {
        transaction.set(likeDocRef, {
          'feedId': postId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(feedDocRef, {'likeCount': FieldValue.increment(1)});
      }
    });
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
  Future<void> addComment(
    String postId,
    String userId,
    String content,
    String userNickname,
    String userImageUrl,
  ) async {
    // runTransaction을 사용하여 두 작업을 하나로 묶음
    await _firestore.runTransaction((transaction) async {
      final commentRef = _firestore.collection('comments').doc();
      final feedDocRef = _firestore.collection('feeds').doc(postId);

      // 1. 댓글 문서 생성 정보 설정
      transaction.set(commentRef, {
        'feedId': postId,
        'userId': userId,
        'userNickname': userNickname,
        'userImageUrl': userImageUrl,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. 해당 피드의 댓글 수 증가
      transaction.update(feedDocRef, {'commentCount': FieldValue.increment(1)});
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
