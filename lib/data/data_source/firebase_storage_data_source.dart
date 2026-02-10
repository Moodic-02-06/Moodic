import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

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
}
