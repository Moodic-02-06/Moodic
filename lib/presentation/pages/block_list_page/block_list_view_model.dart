import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/block.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/provider/blocked_ids_provider.dart';

class BlockListState {
  final List<Block> blocks;
  final bool isLoading;
  final String? errorMessage;

  BlockListState({
    this.blocks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BlockListState copyWith({
    List<Block>? blocks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BlockListState(
      blocks: blocks ?? this.blocks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BlockListViewModel extends Notifier<BlockListState> {
  @override
  BlockListState build() {
    Future.microtask(_loadBlocks);
    return BlockListState();
  }

  Future<void> _loadBlocks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = ref.read(userProvider).value;
      if (user != null) {
        final blocks = await ref
            .read(getBlocksUseCaseProvider)
            .execute(user.uid);
        state = state.copyWith(blocks: blocks, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: '로그인이 필요합니다.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '로드 중 오류 발생: $e');
    }
  }

  Future<void> unblock(String targetId) async {
    try {
      final user = ref.read(userProvider).value;
      if (user != null) {
        await ref
            .read(unblockTargetUseCaseProvider)
            .execute(user.uid, targetId);
        ref.read(blockedIdsProvider.notifier).removeBlockedId(targetId);

        final newBlocks = state.blocks
            .where((b) => b.targetId != targetId)
            .toList();
        state = state.copyWith(blocks: newBlocks);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: '차단 해제 실패: $e');
    }
  }
}

final blockListViewModelProvider =
    NotifierProvider<BlockListViewModel, BlockListState>(() {
      return BlockListViewModel();
    });
