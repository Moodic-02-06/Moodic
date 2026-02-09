import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_keyword_provider.dart';
import 'music_provider.dart';

final searchDebounceProvider = Provider.autoDispose<void>((ref) {
  Timer? timer;

  ref.listen<String>(searchKeywordProvider, (prev, next) {
    timer?.cancel();

    timer = Timer(const Duration(milliseconds: 500), () {
      if (next.trim().isNotEmpty) {
        ref.read(musicProvider.notifier).search(next);
      }
    });
  });

  ref.onDispose(() {
    timer?.cancel();
  });
});
