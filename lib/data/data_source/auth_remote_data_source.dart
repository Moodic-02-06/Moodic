import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_moodic/data/dto/user_dto.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart' hide User;
import 'package:flutter_moodic/domain/entity/user_entity.dart';

class AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signInWithGoogle() async {
    try {
      // 2. Google 계정 선택 UI 띄우기
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
          .signIn();

      // 사용자가 취소했을 경우 처리
      if (googleSignInAccount == null) return null;

      // 3. 로그인된 계정에서 토큰 정보 가져오기
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // 5. Firebase Auth에서 사용할 OAuthCredential 생성
      final OAuthCredential oauthCred = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // 6. Firebase에 로그인 요청
      final UserCredential userCredential = await _auth.signInWithCredential(
        oauthCred,
      );

      // 문서 아이디
      final User? user = userCredential.user;
      if (user == null) return null;

      return user.uid;
    } catch (e) {
      return null;
    }
  }

  Future<String?> signInWithKakao() async {
    try {
      // 1. 카카오톡 설치 여부 확인
      final isInstalled = await isKakaoTalkInstalled();

      // 2. 카카오 로그인 실행 및 토큰 수령
      final OAuthToken oAuthToken = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      // 3. 파이어베이스 인증 정보 생성

      final OAuthProvider oAuthProvider = OAuthProvider('oidc.kakao');
      final OAuthCredential oauthCred = oAuthProvider.credential(
        idToken: oAuthToken.idToken, // 카카오 OIDC를 위해 필수
        accessToken: oAuthToken.accessToken,
      );

      // 4. 파이어베이스 로그인
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCred);

      return userCredential.user?.uid;
    } catch (e) {
      // 사용자가 로그인을 취소한 경우 등 에러 처리

      return null;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  UserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      nickname: user.displayName ?? '익명',
      profileImage: user.photoURL,
      bio: '',
    );
  }

  /// 인증 상태 및 유저 데이터를 실시간으로 감시하는 스트림
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);

      // 유저의 Firestore 문서를 실시간 감시하여 데이터가 바뀔 때마다 스트림 발행
      return FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (doc.exists && doc.data() != null) {
              return UserDto.fromJson(doc.data()!);
            }

            // Firestore에 문서가 없는 신규 유저를 위한 초기 객체 반환
            return UserEntity(
              uid: user.uid,
              nickname: user.displayName ?? '익명',
              profileImage: user.photoURL,
              bio: '',
              isFirst: true,
            );
          });
    });
  }

  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('user').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print("❌ 데이터소스 - 계정 확인 실패: $e");
      return false;
    }
  }
}
