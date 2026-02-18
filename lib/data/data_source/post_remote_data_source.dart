import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import '../../domain/entity/post.dart';
import '../../domain/entity/mood_type.dart';

class PostRemoteDataSource {
  final FirebaseFirestore firestore;

  PostRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Post>> fetchPostsByMusicIds({
    required List<String> musicIds,
    MoodType? mood,
  }) async {
    if (musicIds.isEmpty) return [];

    var query = firestore
        .collection('posts')
        .where('music.id', whereIn: musicIds);

    if (mood != null) {
      query = query.where('mood', isEqualTo: mood.label);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Post(
        postId: data['postId'],
        userId: data['userId'],
        userNickname: data['userNickname'],
        userImageUrl: data['userImageUrl'],
        mood: data['mood'],
        content: data['content'],
        music: Music(
          id: data['music']['id'],
          title: data['music']['title'],
          artist: data['music']['artist'],
          previewUrl: data['music']['previewUrl'],
          artwork: data['music']['artwork'],
          trackUrl: data['music']['trackUrl'],
        ),
        imageUrls: List<String>.from(data['imageUrls']),
        likeCount: data['likeCount'],
        commentCount: data['commentCount'],
        isLikedByMe: data['isLikedByMe'] ?? false,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    }).toList();
  }
}
