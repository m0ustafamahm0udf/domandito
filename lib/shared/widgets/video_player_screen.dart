import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:video_player/video_player.dart';

class CachedVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const CachedVideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
  });

  @override
  State<CachedVideoPlayerScreen> createState() =>
      _CachedVideoPlayerScreenState();
}

class _CachedVideoPlayerScreenState extends State<CachedVideoPlayerScreen> {
  late CachedVideoPlayerPlus _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    setState(() {});
  }

  Future<void> _initializeVideo() async {
    try {
      // Initialize controller directly
      _controller = CachedVideoPlayerPlus.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Auto play
        _controller.controller.play();
      }

      // Listen to video completion and updates
      _controller.controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.controller.value.isPlaying) {
        _controller.controller.pause();
      } else {
        _controller.controller.play();
        _toggleControls();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   // backgroundColor: Colors.black,
      //   iconTheme: const IconThemeData(color: AppColors.primary),
      //   title: widget.title != null
      //       ? Text(
      //           widget.title!,
      //           style: const TextStyle(color: AppColors.primary),
      //         )
      //       : null,
      // ),
      body: Center(
        child: _hasError
            ? _buildErrorWidget()
            : !_isInitialized
            ? _buildLoadingWidget()
            : _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return CupertinoActivityIndicator(color: AppColors.primary);
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 60),
        const SizedBox(height: 20),
        const Text(
          'Error loading video',
          style: TextStyle(color: AppColors.primary, fontSize: 18),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
              _isInitialized = false;
            });
            _initializeVideo();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Video player
          AspectRatio(
            aspectRatio: _controller.controller.value.aspectRatio,
            child: VideoPlayer(_controller.controller),
          ),

          // Controls overlay
          if (_showControls)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Play/Pause button in center
                  Expanded(
                    child: Center(
                      child: IconButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColors.white.withOpacity(0.3),
                          ),
                        ),
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _controller.controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  // Progress bar and controls
                  Column(
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        _controller.controller,
                        allowScrubbing: true,
                        padding: EdgeInsets.zero,

                        colors: VideoProgressColors(
                          playedColor: AppColors.primary,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      // VideoProgressIndicator(

                      //   _controller.controller,
                      //   allowScrubbing: true,
                      //   colors: const VideoProgressColors(
                      //     playedColor: AppColors.primary,
                      //     bufferedColor: Colors.grey,
                      //     backgroundColor: Colors.white24,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),

                      // Time and fullscreen
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _formatDuration(
                                    _controller.controller.value.position,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' / ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: _formatDuration(
                                    _controller.controller.value.duration,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                AppColors.white.withOpacity(0.3),
                              ),
                            ),
                            onPressed: _toggleMute,
                            icon: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // IconButton(
                          //   onPressed: () {
                          //     if (MediaQuery.of(context).orientation ==
                          //         Orientation.portrait) {
                          //       SystemChrome.setPreferredOrientations([
                          //         DeviceOrientation.landscapeLeft,
                          //         DeviceOrientation.landscapeRight,
                          //       ]);
                          //     } else {
                          //       SystemChrome.setPreferredOrientations([
                          //         DeviceOrientation.portraitUp,
                          //       ]);
                          //     }
                          //   },
                          //   icon: const Icon(
                          //     Icons.fullscreen,
                          //     color: Colors.white,
                          //     size: 30,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
