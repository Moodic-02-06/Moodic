import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource(this._storage);

  Future<String> uploadImage({
    required String path,
    required String fileName,
  }) async {
    final file = File(path);
    final ref = _storage.ref(fileName);
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  /// 특정 경로(폴더) 아래의 모든 파일 및 폴더 삭제
  Future<void> deleteFolder(String folderPath) async {
    try {
      final listResult = await _storage.ref(folderPath).listAll();

      // 1. 모든 파일 삭제
      for (final item in listResult.items) {
        await item.delete();
      }

      // 2. 모든 하위 폴더 삭제 (재귀 호출)
      for (final prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }
    } catch (e) {
      // 폴더가 없거나 이미 삭제된 경우 무시
      debugPrint("Storage 폴더 삭제 중 오류 (무시 가능): $e");
    }
  }
}
