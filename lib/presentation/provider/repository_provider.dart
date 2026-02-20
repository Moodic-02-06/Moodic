import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_moodic/data/data_source/fire_store_post_data_source.dart';
import 'package:flutter_moodic/data/data_source/firebase_storage_data_source.dart';
import 'package:flutter_moodic/data/repository/post_repository_impl.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';
import 'package:flutter_moodic/data/data_source/notification_remote_data_source.dart';
import 'package:flutter_moodic/data/repository/notification_repository_impl.dart';
import 'package:flutter_moodic/domain/repository/notification_repository.dart';
import 'package:flutter_moodic/data/data_source/remote/block_remote_data_source.dart';
import 'package:flutter_moodic/data/repository/block_repository_impl.dart';
import 'package:flutter_moodic/domain/repository/block_repository.dart';
import 'package:flutter_moodic/data/data_source/remote/report_remote_data_source.dart';
import 'package:flutter_moodic/data/repository/report_repository_impl.dart';
import 'package:flutter_moodic/domain/repository/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreDataSourceProvider = Provider<FirestorePostDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestorePostDataSource(firestore);
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firebaseStorageDataSourceProvider = Provider<FirebaseStorageDataSource>((
  ref,
) {
  final storage = ref.watch(firebaseStorageProvider);
  return FirebaseStorageDataSource(storage);
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dataSource = ref.watch(firestoreDataSourceProvider);
  final storageDataSource = ref.watch(firebaseStorageDataSourceProvider);
  return PostRepositoryImpl(dataSource, storageDataSource);
});

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource();
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(dataSource);
});

final blockRemoteDataSourceProvider = Provider<BlockRemoteDataSource>((ref) {
  return BlockRemoteDataSource(ref.watch(firestoreProvider));
});

final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  final dataSource = ref.watch(blockRemoteDataSourceProvider);
  return BlockRepositoryImpl(dataSource);
});

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSource(ref.watch(firestoreProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dataSource = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(dataSource);
});
