const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * 탈퇴한 사용자의 데이터를 정리하는 함수
 * - Trigger: Auth User 삭제 시
 * - 삭제 대상:
 *   1. Storage: users/{userId} (프로필 이미지)
 *   2. Storage: posts/{userId} (게시글 이미지)
 *   3. Firestore: feeds 컬렉션의 본인 게시글
 * - 보존 대상:
 *   1. 댓글 (comments)
 *   2. 좋아요 (likes)
 */
exports.cleanupUserData = functions.auth.user().onDelete(async (user) => {
  const userId = user.uid;
  console.log(`[Users Cleanup] Start cleanup for user: ${userId}`);

  const storage = admin.storage().bucket();
  const firestore = admin.firestore();

  // 1. Storage 정리 (프로필 이미지 & 게시글 이미지)
  const storageCleanupPromises = [];

  // 1-1. 프로필 이미지 폴더 (users/{userId}/) 삭제
  // Storage에는 폴더 삭제 개념이 없고, prefix로 검색해서 파일 하나씩 지워야 함.
  const deleteFolder = async (folderPath) => {
    try {
      const [files] = await storage.getFiles({ prefix: folderPath });
      console.log(`[Storage] Found ${files.length} files in ${folderPath}`);
      
      const deletePromises = files.map((file) => file.delete());
      await Promise.all(deletePromises);
      console.log(`[Storage] Deleted files in ${folderPath}`);
    } catch (error) {
      console.error(`[Storage] Error deleting folder ${folderPath}:`, error);
    }
  };

  storageCleanupPromises.push(deleteFolder(`users/${userId}/`));
  storageCleanupPromises.push(deleteFolder(`posts/${userId}/`));

  // 2. Firestore 정리 (Feeds)
  // feeds 컬렉션에서 userId가 일치하는 문서 삭제
  const firestoreCleanup = async () => {
    try {
      const snapshot = await firestore
        .collection("feeds")
        .where("userId", "==", userId)
        .get();

      console.log(`[Firestore] Found ${snapshot.size} feeds to delete.`);

      if (snapshot.empty) return;

      const batch = firestore.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`[Firestore] Deleted feeds for user ${userId}`);
    } catch (error) {
      console.error(`[Firestore] Error deleting feeds:`, error);
    }
  };

  try {
    await Promise.all([
      ...storageCleanupPromises,
      firestoreCleanup(),
    ]);
    console.log(`[Users Cleanup] Successfully cleaned up data for user: ${userId}`);
  } catch (error) {
    console.error(`[Users Cleanup] Failed to cleanup data for user: ${userId}`, error);
  }
});
