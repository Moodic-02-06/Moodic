import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/data/dto/user_dto.dart';

class UserRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // [불러오기] UID로 유저 정보 가져오기
  Future<UserDto?> getUserData(String uid) async {
    final collectionRef = _firestore.collection("user");
    // 유저 컬렉션을 다 가지고 오겠다
    final docRef = collectionRef.doc(uid);
    // 컬렌션 안에 있는 문서를 하나씩 가지고 오겠다
    final snapshot = await docRef.get();
    final data = snapshot.data();

    if (data == null) {
      return null;
    }
    return UserDto.fromJson(data);
  }

  // [삭제] 회원 탈퇴 시
  Future<void> deleteUser(String uid) async {
    final collectionRef = _firestore.collection("user");
    DocumentReference documentRef = collectionRef.doc(uid);
    await documentRef.delete();
  }

  // [수정] 프로필 정보 변경 등
  Future<void> updateUser(UserDto userDto) async {
    final collectionRef = _firestore.collection("user");
    final docRef = collectionRef.doc(userDto.uid);
    docRef.set(userDto.toJson());
  }

  // 저장
  Future<void> saveUser(UserDto userDto) async {
    final collectionRef = _firestore.collection("user");

    await collectionRef.doc(userDto.uid).set(userDto.toJson());
  }

  // [팔로우] 타겟 유저 팔로우
  Future<void> followUser(String uid, String targetUid) async {
    final batch = _firestore.batch();

    // 1. 내 following 컬렉션에 추가
    final myFollowingRef = _firestore
        .collection("user")
        .doc(uid)
        .collection("following")
        .doc(targetUid);
    batch.set(myFollowingRef, {
      "uid": targetUid,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // 2. 상대방 followers 컬렉션에 추가
    final targetFollowerRef = _firestore
        .collection("user")
        .doc(targetUid)
        .collection("followers")
        .doc(uid);
    batch.set(targetFollowerRef, {
      "uid": uid,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // 3. 카운트 증가 (Transaction이 더 안전하지만 일단 Batch로 처리)
    final myUserRef = _firestore.collection("user").doc(uid);
    batch.update(myUserRef, {"followingCount": FieldValue.increment(1)});

    final targetUserRef = _firestore.collection("user").doc(targetUid);
    batch.update(targetUserRef, {"followerCount": FieldValue.increment(1)});

    await batch.commit();
  }

  // [언팔로우] 타겟 유저 언팔로우
  Future<void> unfollowUser(String uid, String targetUid) async {
    final batch = _firestore.batch();

    // 1. 내 following 컬렉션에서 삭제
    final myFollowingRef = _firestore
        .collection("user")
        .doc(uid)
        .collection("following")
        .doc(targetUid);
    batch.delete(myFollowingRef);

    // 2. 상대방 followers 컬렉션에서 삭제
    final targetFollowerRef = _firestore
        .collection("user")
        .doc(targetUid)
        .collection("followers")
        .doc(uid);
    batch.delete(targetFollowerRef);

    // 3. 카운트 감소
    final myUserRef = _firestore.collection("user").doc(uid);
    batch.update(myUserRef, {"followingCount": FieldValue.increment(-1)});

    final targetUserRef = _firestore.collection("user").doc(targetUid);
    batch.update(targetUserRef, {"followerCount": FieldValue.increment(-1)});

    await batch.commit();
  }

  // [팔로우 여부 확인]
  Future<bool> isFollowing(String uid, String targetUid) async {
    final docSnap = await _firestore
        .collection("user")
        .doc(uid)
        .collection("following")
        .doc(targetUid)
        .get();
    return docSnap.exists;
  }

  // [팔로워 목록 조회]
  Future<List<String>> getFollowers(String uid) async {
    final snapshot = await _firestore
        .collection("user")
        .doc(uid)
        .collection("followers")
        .get();
    return snapshot.docs.map((e) => e.id).toList();
  }

  // [팔로잉 목록 조회]
  Future<List<String>> getFollowing(String uid) async {
    final snapshot = await _firestore
        .collection("user")
        .doc(uid)
        .collection("following")
        .get();
    return snapshot.docs.map((e) => e.id).toList();
  }
}
