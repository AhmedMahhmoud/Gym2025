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
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize YouTube player controller with the video ID
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoId)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        showLiveFullscreenButton: false,
        disableDragSeek: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  /// Navigate to full-screen video player
  void _navigateToFullScreen(BuildContext context) async {
    final isPlaying = _controller.value.isPlaying;

    // Pause the embedded player before navigating
    if (isPlaying) {
      _controller.pause();
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: YoutubePlayer(
          controller: _controller,
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
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize a separate controller for the full-screen player
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoId)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        showLiveFullscreenButton: false,
        disableDragSeek: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the full-screen controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
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
