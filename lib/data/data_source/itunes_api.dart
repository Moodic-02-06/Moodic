import 'dart:convert';
import 'package:http/http.dart' as http;

import '../dto/music_dto.dart';

class ItunesApi {
  static Future<List<MusicDto>> search(String keyword) async {
    final url = Uri.parse(
      'https://itunes.apple.com/search'
      '?term=$keyword'
      '&entity=song'
      '&limit=30',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('검색 실패');
    }

    final json = jsonDecode(response.body);

    final List list = json['results'];

    return list.map((e) => MusicDto.fromJson(e)).toList();
  }
}
