import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'music_dto.dart';

class PostDto {
  final String postId;
  final String userId;
  final String userNickname;
  final String userImageUrl;
  final String mood;
  final String content;
  final MusicDto music;
  final List<String> imageUrls;
  final int likeCount;
  final int commentCount;
  final bool isLikedByMe;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PostDto({
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
    required this.isLikedByMe,
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
      userId: json['userId'] as String? ?? '',
      userNickname: json['userNickname'] as String? ?? '익명',
      userImageUrl: json['userImageUrl'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      content: json['content'] as String? ?? '',
      music: MusicDto.fromJson(json['music'] as Map<String, dynamic>? ?? {}),
      imageUrls: (json['imageUrls'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      likeCount: (json['likeCount'] is int)
          ? json['likeCount'] as int
          : (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] is int)
          ? json['commentCount'] as int
          : (json['commentCount'] as num?)?.toInt() ?? 0,
      isLikedByMe: isLikedByMe,
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt'] as Timestamp
          : Timestamp.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? json['updatedAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userNickname': userNickname,
      'userImageUrl': userImageUrl,
      'mood': mood,
      'content': content,
      'music': music.toJson(),
      'imageUrls': imageUrls,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLikedByMe': isLikedByMe,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // DTO → Entity 변환
  Post toEntity() {
    return Post(
      postId: postId,
      userId: userId,
      userNickname: userNickname,
      userImageUrl: userImageUrl,
      mood: mood,
      content: content,
      music: music.toEntity(),
      imageUrls: imageUrls,
      likeCount: likeCount,
      commentCount: commentCount,
      isLikedByMe: isLikedByMe,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }
}
