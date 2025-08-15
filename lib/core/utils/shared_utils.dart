class SharedUtils {
  static String extractThumbnail(String url) {
    // If URL is empty, return fallback image
    if (url.isEmpty) {
      return 'assets/images/imgNotFound.jpg';
    }

    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        return 'https://img.youtube.com/vi/$videoId/0.jpg';
      }
    }

    // If it's a direct image URL, return it as is
    if (url.toLowerCase().contains('.jpg') ||
        url.toLowerCase().contains('.jpeg') ||
        url.toLowerCase().contains('.png') ||
        url.toLowerCase().contains('.gif') ||
        url.toLowerCase().contains('.webp')) {
      return url;
    }

    // Return fallback image for all other cases
    return 'assets/images/imgNotFound.jpg';
  }
}
