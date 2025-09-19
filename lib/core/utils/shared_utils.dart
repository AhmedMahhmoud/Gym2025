import 'dart:io';
import 'package:http/http.dart' as http;

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

  /// Check if a YouTube video is available by testing the thumbnail URL
  static Future<bool> isVideoAvailable(String url) async {
    if (url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        try {
          final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
          final response = await http.get(Uri.parse(thumbnailUrl));

          // YouTube returns a specific image for unavailable videos
          // We can check the response size or content to determine if video is available
          // For now, let's check if we get a successful response and reasonable content length
          return response.statusCode == 200 && response.bodyBytes.length > 1000;
        } catch (e) {
          return false;
        }
      }
    }

    // For non-YouTube URLs, assume they're available if not empty
    return url.isNotEmpty;
  }

  /// Get thumbnail with availability check - returns fallback if video is unavailable
  static Future<String> extractThumbnailWithAvailability(String url) async {
    if (url.isEmpty) {
      return 'assets/images/imgNotFound.jpg';
    }

    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        final isAvailable = await isVideoAvailable(url);
        if (isAvailable) {
          return 'https://img.youtube.com/vi/$videoId/0.jpg';
        } else {
          return 'assets/images/imgNotFound.jpg';
        }
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

  /// Test method to check if a specific YouTube video is available
  /// This can be used for debugging purposes
  static Future<void> testVideoAvailability(String url) async {
    print('Testing video availability for: $url');

    if (url.isEmpty) {
      print('URL is empty - video unavailable');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        print('YouTube video ID: $videoId');

        try {
          final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
          print('Thumbnail URL: $thumbnailUrl');

          final response = await http.get(Uri.parse(thumbnailUrl));
          print('Response status: ${response.statusCode}');
          print('Response size: ${response.bodyBytes.length} bytes');

          final isAvailable =
              response.statusCode == 200 && response.bodyBytes.length > 5000;
          print('Video available: $isAvailable');
        } catch (e) {
          print('Error checking video: $e');
        }
      } else {
        print('No video ID found in URL');
      }
    } else {
      print('Not a YouTube URL');
    }
  }
}
