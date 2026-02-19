import 'music.dart';

class Post {
  final String postId;
  final String userId;
  final String userNickname;
  final String userImageUrl;
  final String mood;
  final String content;
  final Music music;
  final List<String> imageUrls;
  final int likeCount;
  final int commentCount;
  bool isLikedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.postId,
    required this.userId,
    required this.userNickname,
    required this.userImageUrl,
    required this.mood,
    required this.content,
    required this.music,
    required this.imageUrls,
    required this.likeCount,
    required this.commentCount,
    this.isLikedByMe = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Post copyWith({
    String? postId,
    String? userId,
    String? userNickname,
    String? userImageUrl,
    String? mood,
    String? content,
    Music? music,
    List<String>? imageUrls,
    int? likeCount,
    int? commentCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      music: music ?? this.music,
      imageUrls: imageUrls ?? this.imageUrls,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
