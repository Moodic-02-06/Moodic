import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchKeywordNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void set(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final searchKeywordProvider = NotifierProvider<SearchKeywordNotifier, String>(
  SearchKeywordNotifier.new,
);
