class SharedUtils {
  static String extractThumbnail(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    }
    return '';
  }
}
