import 'package:flutter_moodic/domain/entity/music.dart';

class MusicDto extends Music {
  MusicDto({
    required super.id,
    required super.title,
    required super.artist,
    required super.previewUrl,
    required super.artwork,
    required super.trackUrl,
  });

  factory MusicDto.fromJson(Map<String, dynamic> json) {
    return MusicDto(
      id: json['trackId']?.toString() ?? '',
      title: json['trackName'] as String? ?? '',
      artist: json['artistName'] as String? ?? '',
      previewUrl: json['previewUrl'] as String? ?? '',
      artwork: json['artworkUrl100'] as String? ?? '',
      trackUrl: json['trackViewUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': id,
      'trackName': title,
      'artistName': artist,
      'previewUrl': previewUrl,
      'artworkUrl100': artwork,
      'trackViewUrl': trackUrl,
    };
  }

  Music toEntity() {
    return Music(
      id: id,
      title: title,
      artist: artist,
      previewUrl: previewUrl,
      artwork: artwork,
      trackUrl: trackUrl,
    );
  }

  factory MusicDto.fromEntity(Music music) {
    return MusicDto(
      id: music.id,
      title: music.title,
      artist: music.artist,
      previewUrl: music.previewUrl,
      artwork: music.artwork,
      trackUrl: music.trackUrl,
    );
  }
}
