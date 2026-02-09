import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/data/repository/post_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';
import 'package:flutter_moodic/data/data_source/fire_store_post_data_source.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dataSource = FirestorePostDataSource(FirebaseFirestore.instance);
  return PostRepositoryImpl(dataSource);
});
