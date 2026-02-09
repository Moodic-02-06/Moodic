import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/data/repository/post_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/repositories/post_repository.dart';
import 'package:flutter_moodic/data/data_source/fire_store_post_data_source.dart';

// PostRepository를 주입해주는 Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dataSource = FirestorePostDataSource(FirebaseFirestore.instance);
  return PostRepositoryImpl(dataSource);
});
