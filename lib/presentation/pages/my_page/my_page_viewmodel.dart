import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPageState {
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;

  MyPageState({required this.feeds, this.isLoading = false, this.errorMessage});

  MyPageState copyWith({
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyPageState(
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MyPageViewmodel extends Notifier<MyPageState> {
  @override
  MyPageState build() {
    return MyPageState(feeds: []);
  }
}
