class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String userNickname;
  final String userImageUrl;
  final String content;
  final DateTime createdAt;
  final String? parentId;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userNickname,
    required this.userImageUrl,
    required this.content,
    required this.createdAt,
    this.parentId,
  });
}
