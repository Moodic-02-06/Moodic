import 'package:flutter_moodic/domain/usecase/delete_post_usecase.dart';
import 'package:flutter_moodic/domain/usecase/fetch_feeds_usecase.dart';
import 'package:flutter_moodic/domain/usecase/search_result_usecase.dart';
import 'package:flutter_moodic/domain/usecase/toggle_like_usecase.dart';
import 'package:flutter_moodic/domain/usecase/update_post_usecase.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/domain/usecase/notification/create_notification_usecase.dart';
import 'package:flutter_moodic/domain/usecase/notification/listen_notifications_usecase.dart';
import 'package:flutter_moodic/domain/usecase/block_target_usecase.dart';
import 'package:flutter_moodic/domain/usecase/get_blocked_ids_usecase.dart';
import 'package:flutter_moodic/domain/usecase/report_target_usecase.dart';
import 'package:flutter_moodic/domain/usecase/get_my_reports_usecase.dart';
import 'package:flutter_moodic/domain/usecase/get_blocks_usecase.dart';
import 'package:flutter_moodic/domain/usecase/unblock_target_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  return ToggleLikeUseCase(ref.read(postRepositoryProvider));
});

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  return DeletePostUseCase(ref.read(postRepositoryProvider));
});

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  return UpdatePostUseCase(ref.read(postRepositoryProvider));
});

final fetchFeedsUseCaseProvider = Provider<FetchFeedsUseCase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return FetchFeedsUseCase(repo);
});

final searchByMoodUseCaseProvider = Provider<SearchByMoodUseCase>((ref) {
  return SearchByMoodUseCase(ref.read(postRepositoryProvider));
});

final searchByMusicIdUseCaseProvider = Provider<SearchByMusicIdUseCase>((ref) {
  return SearchByMusicIdUseCase(ref.read(postRepositoryProvider));
});
final createNotificationUseCaseProvider = Provider<CreateNotificationUseCase>((
  ref,
) {
  return CreateNotificationUseCase(ref.read(notificationRepositoryProvider));
});

final listenNotificationsUseCaseProvider = Provider<ListenNotificationsUseCase>(
  (ref) {
    return ListenNotificationsUseCase(ref.read(notificationRepositoryProvider));
  },
);

final blockTargetUseCaseProvider = Provider<BlockTargetUseCase>((ref) {
  return BlockTargetUseCase(ref.read(blockRepositoryProvider));
});

// 기존 프로바이더들 ... (GetBlockedIdsUseCase, ReportTargetUseCase 등)
final getBlockedIdsUseCaseProvider = Provider<GetBlockedIdsUseCase>((ref) {
  return GetBlockedIdsUseCase(ref.read(blockRepositoryProvider));
});

final reportTargetUseCaseProvider = Provider<ReportTargetUseCase>((ref) {
  return ReportTargetUseCase(ref.read(reportRepositoryProvider));
});

final unblockTargetUseCaseProvider = Provider<UnblockTargetUseCase>((ref) {
  return UnblockTargetUseCase(ref.read(blockRepositoryProvider));
});

final getBlocksUseCaseProvider = Provider<GetBlocksUseCase>((ref) {
  return GetBlocksUseCase(ref.read(blockRepositoryProvider));
});

final getMyReportsUseCaseProvider = Provider<GetMyReportsUseCase>((ref) {
  return GetMyReportsUseCase(ref.read(reportRepositoryProvider));
});
