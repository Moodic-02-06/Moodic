import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/domain/entity/comment.dart';

class CommentDto {
  final String commentId;
  final String postId;
  final String userId;
  final String userNickname;
  final String userImageUrl;
  final String content;
  final Timestamp createdAt;

  CommentDto({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userNickname,
    required this.userImageUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json, String id) {
    return CommentDto(
      commentId: id,
      postId: json['feedId'] as String,
      userId: json['userId'] as String,
      userNickname: json['userNickname'] as String,
      userImageUrl: json['userImageUrl'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedId': postId,
      'userId': userId,
      'userNickname': userNickname,
      'userImageUrl': userImageUrl,
      'content': content,
      'createdAt': createdAt,
    };
  }

  // DTO → Entity 변환
  Comment toEntity() {
    return Comment(
      commentId: commentId,
      postId: postId,
      userId: userId,
      userNickname: userNickname,
      userImageUrl: userImageUrl,
      content: content,
      createdAt: createdAt.toDate(),
    );
  }
}
