import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockedIdsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  Future<void> loadBlockedIds() async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    try {
      final useCase = ref.read(getBlockedIdsUseCaseProvider);
      final ids = await useCase.execute(user.uid);
      state = ids;
    } catch (e) {
      // 로드 실패 시 빈 리스트 유지
    }
  }

  void addBlockedId(String id) {
    if (!state.contains(id)) {
      state = [...state, id];
    }
  }

  void removeBlockedId(String id) {
    if (state.contains(id)) {
      state = state.where((element) => element != id).toList();
    }
  }
}

final blockedIdsProvider = NotifierProvider<BlockedIdsNotifier, List<String>>(
  () {
    return BlockedIdsNotifier();
  },
);
