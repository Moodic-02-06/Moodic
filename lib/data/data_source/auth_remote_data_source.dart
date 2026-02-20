import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moodic/data/data_source/firebase_storage_data_source.dart';
import 'package:flutter_moodic/data/dto/user_dto.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart' hide User;
import 'package:flutter_moodic/domain/entity/user_entity.dart';

class AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 회원탈퇴 진행 중 플래그 (탈퇴 중에는 스트림이 null을 반환하도록)
  bool _isDeleting = false;

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
      debugPrint("데이터소스 - 구글 로그인 실패: $e");
      rethrow;
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
      debugPrint("데이터소스 - 카카오 로그인 실패: $e");
      rethrow;
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
      followerCount: 0,
      followingCount: 0,
    );
  }

  /// 인증 상태 및 유저 데이터를 실시간으로 감시하는 스트림
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncExpand((user) {
      // 회원탈퇴 진행 중이면 무조건 로그아웃 상태로 처리
      if (_isDeleting) return Stream.value(null);

      if (user == null) return Stream.value(null);

      // 유저의 Firestore 문서를 실시간 감시하여 데이터가 바뀔 때마다 스트림 발행
      return FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            // 탈퇴 진행 중이면 로그아웃 상태 반환
            if (_isDeleting) return null;

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
              followerCount: 0,
              followingCount: 0,
            );
          });
    });
  }

  /// 소셜 로그인 등의 과정에서 유저 정보가 있는지 확인하고 없으면 생성
  Future<UserDto> getOrCreateUser(UserEntity user) async {
    final doc = await _firestore.collection('user').doc(user.uid).get();
    if (doc.exists) {
      return UserDto.fromJson(doc.data()!);
    } else {
      final newUser = UserDto(
        uid: user.uid,
        nickname: user.nickname,
        profileImage: user.profileImage,
        bio: user.bio,
        isFirst: true,
        postCount: 0,
        followerCount: 0,
        followingCount: 0,
        isNotificationEnabled: true,
      );
      await _firestore.collection('user').doc(user.uid).set(newUser.toJson());
      return newUser;
    }
  }

  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('user').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint("데이터소스 - 계정 확인 실패: $e");
      rethrow;
    }
  }

  /// 회원 탈퇴: Firestore 데이터 삭제 + Firebase Auth 계정 삭제
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인된 유저가 없습니다.');
    }

    try {
      // 탈퇴 시작 플래그 설정 (스트림이 로그아웃 상태를 반환하도록)
      _isDeleting = true;

      // 1. 소셜 로그인 연결 해제 (Unlink)
      // 1-1. Google 연결 해제
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      // 1-2. Kakao 연결 해제 (카카오톡 앱 또는 카카오계정 로그인 모두 처리됨)
      try {
        final hasToken = await AuthApi.instance.hasToken();
        if (hasToken) {
          await UserApi.instance.unlink();
        }
      } catch (e) {
        debugPrint("카카오 언링크 실패 (무시 가능): $e");
      }

      // 1-3. Firebase Storage 데이터 삭제 (프로필 및 게시물 이미지)
      final storageDataSource = FirebaseStorageDataSource(
        FirebaseStorage.instance,
      );
      try {
        await storageDataSource.deleteFolder('users/${user.uid}');
        await storageDataSource.deleteFolder('posts/${user.uid}');
      } catch (e) {
        debugPrint("스토리지 데이터 삭제 실패 (무시 가능): $e");
      }

      // 2. Firestore 문서 삭제 (Batch 사용)
      final batch = _firestore.batch();

      // 2-1. 내 하위 컬렉션(followers, following) 삭제
      // 참고: 컬렉션 자체를 지우는 API는 없으므로 문서를 가져와서 지워야 합니다.
      final followersSnapshot = await _firestore
          .collection('user')
          .doc(user.uid)
          .collection('followers')
          .get();
      for (final doc in followersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final followingSnapshot = await _firestore
          .collection('user')
          .doc(user.uid)
          .collection('following')
          .get();
      for (final doc in followingSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 2-2. 유저의 포스트 삭제 (포스트 자체 삭제)
      final postsSnapshot = await _firestore
          .collection('feeds')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (final doc in postsSnapshot.docs) {
        batch.delete(doc.reference);
        // (선택) 만약 게시물 아래에 comments, likes 하위 컬렉션이 있다면
        // 완벽하게 지우려면 Cloud Functions를 쓰는 것이 좋으나,
        // 클라이언트에서는 게시물 자체만 지워도 뷰에 노출되지 않음.
      }

      // 2-3. 유저의 댓글 익명화 ("탈퇴된 사용자"로 변경)
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (final doc in commentsSnapshot.docs) {
        batch.update(doc.reference, {
          'userNickname': '탈퇴된 사용자',
          'userImageUrl': '', // 이미지 제거
        });
      }

      // 3. (중요) 고아 데이터 정리: 다른 사람의 팔로워/팔로잉 목록에서 내 UID 지우기
      // 내가 팔로잉했던 사람들의 followers에서 나를 지움
      for (final doc in followingSnapshot.docs) {
        final targetFollowerRef = _firestore
            .collection("user")
            .doc(doc.id)
            .collection("followers")
            .doc(user.uid);
        batch.delete(targetFollowerRef);
        // 상대방의 카운트 감소
        batch.update(_firestore.collection("user").doc(doc.id), {
          "followerCount": FieldValue.increment(-1),
        });
      }

      // 나를 팔로우했던 사람들의 following에서 나를 지움
      for (final doc in followersSnapshot.docs) {
        final targetFollowingRef = _firestore
            .collection("user")
            .doc(doc.id)
            .collection("following")
            .doc(user.uid);
        batch.delete(targetFollowingRef);
        // 상대방의 카운트 감소
        batch.update(_firestore.collection("user").doc(doc.id), {
          "followingCount": FieldValue.increment(-1),
        });
      }

      // 2-4. 유저 문서 자체 삭제
      final userRef = _firestore.collection('user').doc(user.uid);
      batch.delete(userRef);

      // 모든 Firestore 처리 커밋
      await batch.commit();

      // 4. Firebase Auth 계정 삭제
      // (재인증이 필요할 수 있음 - 오래된 세션일 경우 user.delete()에서 require-recent-login 에러 발생 가능)
      // 현업에서는 여기서 에러가 나면 사용자에게 '다시 로그인 후 시도해주세요' 알림을 띄웁니다.
      await user.delete();

      // 5. 로그아웃 처리 (혹시 모를 잔여 세션 정리)
      debugPrint("탈퇴 단계: 로그아웃 처리");
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth 에러 발생: ${e.code} - ${e.message}");
      if (e.code == 'requires-recent-login') {
        throw Exception('보안을 위해 다시 로그인한 후 탈퇴를 진행해주세요.');
      }
      throw Exception('인증 서버 오류: ${e.message}');
    } on FirebaseException catch (e) {
      // 💡 Firestore나 Storage 권한 에러 처리용
      debugPrint("Firebase 서비스 에러 발생 (${e.code}): ${e.message}");
      throw Exception('데이터 접근 권한 오류가 발생했습니다. 보안 규칙을 확인해주세요. (${e.code})');
    } catch (e) {
      debugPrint("회원탈퇴 기타 상세 오류: $e");
      throw Exception('회원탈퇴 중 알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      // 탈퇴 완료 또는 실패 시 플래그 해제
      _isDeleting = false;
    }
  }
}
