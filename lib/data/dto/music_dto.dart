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
      id: json['trackId'].toString(),
      title: json['trackName'],
      artist: json['artistName'],
      previewUrl: json['previewUrl'],
      artwork: json['artworkUrl100'],
      trackUrl: json['trackViewUrl'],
    );
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
}
