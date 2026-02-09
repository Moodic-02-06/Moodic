class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });
}
