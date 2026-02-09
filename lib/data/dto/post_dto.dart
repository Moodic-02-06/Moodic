import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'music_dto.dart';

class PostDto {
  final String postId;
  final String userId;
  final String mood;
  final String content;
  final MusicDto music;
  final int likeCount;
  final int commentCount;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PostDto({
    required this.postId,
    required this.userId,
    required this.mood,
    required this.content,
    required this.music,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostDto.fromJson(
    Map<String, dynamic> json,
    String id, {
    bool isLikedByMe = false,
  }) {
    return PostDto(
      postId: id,
      userId: json['userId'] as String,
      mood: json['mood'] as String,
      content: json['content'] as String,
      music: MusicDto.fromJson(json['music'] as Map<String, dynamic>),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mood': mood,
      'content': content,
      'music': music.toJson(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // DTO → Entity 변환
  Post toEntity({bool isLikedByMe = false}) {
    return Post(
      postId: postId,
      userId: userId,
      mood: mood,
      content: content,
      music: music.toEntity(),
      likeCount: likeCount,
      commentCount: commentCount,
      isLikedByMe: isLikedByMe,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }
}
