import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeIframeWidget extends StatefulWidget {
  final String videoId;

  const YoutubeIframeWidget({required this.videoId});

  @override
  _YoutubeIframeWidgetState createState() => _YoutubeIframeWidgetState();
}

class _YoutubeIframeWidgetState extends State<YoutubeIframeWidget>
    with AutomaticKeepAliveClientMixin {
  late YoutubePlayerController? _controller;
  String? _validVideoId;
  bool _hasValidVideo = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Check if videoId is empty or null
    if (widget.videoId.isEmpty) {
      _hasValidVideo = false;
      return;
    }

    // Try to convert URL to video ID
    _validVideoId = YoutubePlayer.convertUrlToId(widget.videoId);

    if (_validVideoId != null && _validVideoId!.isNotEmpty) {
      _hasValidVideo = true;
      // Initialize YouTube player controller with the video ID
      _controller = YoutubePlayerController(
        initialVideoId: _validVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          showLiveFullscreenButton: false,
          disableDragSeek: true,
        ),
      );
    } else {
      _hasValidVideo = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  /// Navigate to full-screen video player
  void _navigateToFullScreen(BuildContext context) async {
    if (!_hasValidVideo || _controller == null) return;

    final isPlaying = _controller!.value.isPlaying;

    // Pause the embedded player before navigating
    if (isPlaying) {
      _controller!.pause();
    }

    // Navigate to the full-screen player
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          videoId: widget.videoId,
          autoPlay: isPlaying,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height / 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Video not available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Invalid or missing video URL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Show error widget if video is not valid
    if (!_hasValidVideo || _controller == null) {
      return _buildErrorWidget();
    }

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: YoutubePlayer(
          controller: _controller!,
          bottomActions: [
            CurrentPosition(),
            ProgressBar(isExpanded: true),
            IconButton(
              color: Colors.white,
              icon: const Icon(
                Icons.fullscreen,
                size: 25,
              ),
              onPressed: () => _navigateToFullScreen(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoId,
    required this.autoPlay,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late YoutubePlayerController? _controller;
  String? _validVideoId;
  bool _hasValidVideo = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Check if videoId is empty or null
    if (widget.videoId.isEmpty) {
      _hasValidVideo = false;
      return;
    }

    // Try to convert URL to video ID
    _validVideoId = YoutubePlayer.convertUrlToId(widget.videoId);

    if (_validVideoId != null && _validVideoId!.isNotEmpty) {
      _hasValidVideo = true;
      // Initialize a separate controller for the full-screen player
      _controller = YoutubePlayerController(
        initialVideoId: _validVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          showLiveFullscreenButton: false,
          disableDragSeek: false,
        ),
      );
    } else {
      _hasValidVideo = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose the full-screen controller
    super.dispose();
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Video not available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Invalid or missing video URL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error widget if video is not valid
    if (!_hasValidVideo || _controller == null) {
      return _buildErrorWidget();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _controller!,
          aspectRatio: MediaQuery.sizeOf(context).width /
              MediaQuery.sizeOf(context).height,
          bottomActions: [
            CurrentPosition(),
            ProgressBar(isExpanded: true),
            IconButton(
              icon: const Icon(
                Icons.fullscreen_exit,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the original screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
