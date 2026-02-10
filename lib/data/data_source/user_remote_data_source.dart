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

  //저장
  Future<void> saveUser(UserDto userDto) async {
    final collectionRef = _firestore.collection("user");

    await collectionRef.doc(userDto.uid).set(userDto.toJson());
  }
}
