import 'dart:io';

import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

class MediaPreviewSection extends StatelessWidget {
  final List<String> localImagePaths;
  final String? localVideoPath;
  final String? videoThumbnailPath;
  final String? videoSizeText;
  final String? videoDurationText;
  final Function(int) onRemoveImage;
  final VoidCallback onRemoveVideo;

  const MediaPreviewSection({
    super.key,
    required this.localImagePaths,
    required this.localVideoPath,
    required this.videoThumbnailPath,
    required this.videoSizeText,
    required this.videoDurationText,
    required this.onRemoveImage,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (localImagePaths.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: localImagePaths.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(localImagePaths[index]),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        if (localImagePaths.isNotEmpty) const SizedBox(height: 10),

        if (localVideoPath != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: videoThumbnailPath != null
                    ? Image.file(
                        File(videoThumbnailPath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 400,
                      )
                    : Container(
                        width: double.infinity,
                        height: 400,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        videoSizeText ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (videoDurationText != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.timer, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          videoDurationText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemoveVideo,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
