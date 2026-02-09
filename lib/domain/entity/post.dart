import 'music.dart';

class Post {
  final String postId;
  final String userId;
  final String mood;
  final String content;
  final Music music;
  final int likeCount;
  final int commentCount;
  bool isLikedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.postId,
    required this.userId,
    required this.mood,
    required this.content,
    required this.music,
    required this.likeCount,
    required this.commentCount,
    this.isLikedByMe = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Post copyWith({
    String? postId,
    String? userId,
    String? mood,
    String? content,
    Music? music,
    int? likeCount,
    int? commentCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      music: music ?? this.music,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
