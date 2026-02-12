String _normalizeSearchText(String text) {
  // 괄호, 특수문자 제거
  return text
      .replaceAll(RegExp(r'\([^)]*\)'), '') // (feat.xxx) 제거
      .replaceAll(RegExp(r'[^\w\s]'), '') // 특수문자 제거
      .replaceAll(RegExp(r'\s+'), ' ') // 공백 정리
      .trim();
}

String buildSpotifySearchUrl(String artist, String title) {
  final cleanArtist = _normalizeSearchText(artist);
  final cleanTitle = _normalizeSearchText(title);

  final query = Uri.encodeComponent('$cleanArtist $cleanTitle');

  // 앱 전용 딥링크
  return 'spotify:search:$query';
}

String buildYoutubeMusicSearchUrl(String artist, String title) {
  final query = Uri.encodeQueryComponent('$artist $title');
  return 'https://music.youtube.com/search?q=$query';
}
