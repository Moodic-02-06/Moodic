import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/post_dto.dart';
import '../dto/comment_dto.dart';

class FirestorePostDataSource {
  final FirebaseFirestore _firestore;

  FirestorePostDataSource(this._firestore);

  /// 최신 피드 가져오기 (Stream)
  Stream<List<PostDto>> getFeedsStream({int limit = 20, String? authorId}) {
    Query query = _firestore.collection('feeds');

    if (authorId != null) {
      query = query.where('userId', isEqualTo: authorId);
    }

    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostDto.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
              // Repository에서 처리하므로 여기서는 false로 둠
              isLikedByMe: false,
            );
          }).toList();
        });
  }

  /// 월별 포스트 가져오기 (통계용이므로 Future 유지)
  Future<List<PostDto>> fetchPostsByMonth(
    String userId,
    int year,
    int month,
  ) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));

    final snapshot = await _firestore
        .collection('feeds')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .get();

    return snapshot.docs
        .map((doc) => PostDto.fromJson(doc.data(), doc.id, isLikedByMe: false))
        .toList();
  }

  /// 특정 포스트 가져오기 (Stream)
  Stream<PostDto> getPostStream(String postId) {
    return _firestore.collection('feeds').doc(postId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception("해당 포스트를 찾을 수 없습니다.");
      }
      return PostDto.fromJson(
        doc.data()!,
        doc.id,
        isLikedByMe: false, // Repository에서 처리
      );
    });
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
      final feedDoc = await transaction.get(feedDocRef);
      if (!feedDoc.exists) throw Exception("Post does not exist!");

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

  /// 댓글 조회 (Stream)
  Stream<List<CommentDto>> getCommentsStream(String postId) {
    return _firestore
        .collection('comments')
        .where('feedId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommentDto.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// 댓글 추가
  Future<void> addComment(
    String postId,
    String userId,
    String content,
    String userNickname,
    String userImageUrl,
  ) async {
    await _firestore.runTransaction((transaction) async {
      final commentRef = _firestore.collection('comments').doc();
      final feedDocRef = _firestore.collection('feeds').doc(postId);

      transaction.set(commentRef, {
        'feedId': postId,
        'userId': userId,
        'userNickname': userNickname,
        'userImageUrl': userImageUrl,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });

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

  /// 댓글 삭제
  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore.runTransaction((transaction) async {
      final commentRef = _firestore.collection('comments').doc(commentId);
      final feedDocRef = _firestore.collection('feeds').doc(postId);

      transaction.delete(commentRef);
      transaction.update(feedDocRef, {
        'commentCount': FieldValue.increment(-1),
      });
    });
  }

  /// 내가 좋아요한 피드 ID 목록 가져오기 (Helper)
  Future<Set<String>> fetchLikedFeedIds(
    String userId,
    List<String> feedIds,
  ) async {
    if (feedIds.isEmpty) return {};

    // Firestore whereIn은 최대 10개까지만 지원하므로, 10개씩 끊어서 요청해야 함
    // 하지만 일단 간단하게 feedIds가 10개 이하라고 가정하거나, chunk 처리를 함
    // 피드 로드 limit이 20이므로 chunk 처리 필수.

    final Set<String> likedFeedIds = {};
    final chunks = [];
    for (var i = 0; i < feedIds.length; i += 10) {
      chunks.add(
        feedIds.sublist(i, i + 10 > feedIds.length ? feedIds.length : i + 10),
      );
    }

    for (var chunk in chunks) {
      final snapshot = await _firestore
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .where('feedId', whereIn: chunk)
          .get();

      for (var doc in snapshot.docs) {
        likedFeedIds.add(doc['feedId'] as String);
      }
    }

    return likedFeedIds;
  }

  /// 내가 좋아요한 피드 목록 가져오기 (Stream)
  Stream<List<PostDto>> fetchLikedFeedsStream(String userId) {
    // 1. likes 컬렉션에서 내가 좋아요한 목록을 실시간 감시
    return _firestore
        .collection('likes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            return [];
          }

          // 2. feedId 목록 추출
          final feedIds = snapshot.docs
              .map((doc) => doc['feedId'] as String)
              .toList();

          // 3. feeds 컬렉션에서 해당 피드 정보 조회
          // whereIn은 최대 10개 제한이 있으므로 청크 처리 필요
          // (여기서는 간단히 20개 제한으로 가정하고 상위 10개만 조회하거나 반복 조회)
          final List<PostDto> posts = [];
          final chunks = [];
          for (var i = 0; i < feedIds.length; i += 10) {
            chunks.add(
              feedIds.sublist(
                i,
                i + 10 > feedIds.length ? feedIds.length : i + 10,
              ),
            );
          }

          for (var chunk in chunks) {
            final feedSnapshot = await _firestore
                .collection('feeds')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

            posts.addAll(
              feedSnapshot.docs.map(
                (doc) => PostDto.fromJson(
                  doc.data(),
                  doc.id,
                  isLikedByMe: true, // 내가 좋아요한 목록이므로 true
                ),
              ),
            );
          }

          // 4. 원래 좋아요 순서대로 정렬 (Firestore whereIn은 순서 보장 안 함)
          // feedIds 순서(좋아요 최신순)에 맞춰 posts 정렬
          final Map<String, PostDto> postMap = {
            for (var post in posts) post.postId: post,
          };

          return feedIds.map((id) => postMap[id]).whereType<PostDto>().toList();
        });
  }
}
