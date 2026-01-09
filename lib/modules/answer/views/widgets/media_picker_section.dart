import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/show_image_picker.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:svg_flutter/svg.dart';

class MediaPickerSection extends StatelessWidget {
  final bool isEditMode;
  final bool hasExistingMedia;
  final bool isExistingVideo; // true if video, false if images
  final String mediaType; // 'none', 'image', 'video'
  final int localImagesCount;
  final int maxImages;
  final Function(ImageSource) onPickImage;
  final Function(ImageSource) onPickVideo;

  const MediaPickerSection({
    super.key,
    required this.isEditMode,
    required this.hasExistingMedia,
    required this.isExistingVideo,
    required this.mediaType,
    required this.localImagesCount,
    required this.maxImages,
    required this.onPickImage,
    required this.onPickVideo,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode && hasExistingMedia) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExistingVideo ? Icons.videocam : Icons.image,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isExistingVideo
                  ? (!context.isCurrentLanguageAr()
                        ? 'Video selected'
                        : 'تم اختيار فيديو')
                  : (!context.isCurrentLanguageAr()
                        ? 'Images selected'
                        : 'تم اختيار صور'),
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (mediaType == 'none')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final ImageSource? source = await showDialog<ImageSource>(
                        context: context,
                        builder: (context) => const ImagePickerSheet(),
                      );
                      if (source != null) {
                        onPickImage(source);
                      }
                    },
                    child: Column(
                      children: [
                        SvgPicture.asset(AppIcons.addImage, height: 40),
                        const SizedBox(height: 8),
                        Text(
                          !context.isCurrentLanguageAr()
                              ? 'Add images'
                              : 'إضافة صور',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: const VerticalDivider(
                    color: AppColors.primary,
                    thickness: 0.3,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final ImageSource? source = await showDialog<ImageSource>(
                        context: context,
                        builder: (context) => const ImagePickerSheet(),
                      );
                      if (source != null) {
                        onPickVideo(source);
                      }
                    },
                    child: Column(
                      children: [
                        SvgPicture.asset(AppIcons.video, height: 40),
                        const SizedBox(height: 8),
                        Text(
                          !context.isCurrentLanguageAr()
                              ? 'Add video'
                              : 'إضافة فيديو',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (mediaType == 'image')
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (localImagesCount < maxImages)
                IconButton(
                  onPressed: () async {
                    if (localImagesCount >= maxImages) {
                      AppConstance().showErrorToast(
                        context,
                        msg: !context.isCurrentLanguageAr()
                            ? 'You can add up to 4 images'
                            : 'يمكنك إضافة 4 صور كحد أقصى',
                      );
                      return;
                    }

                    final ImageSource? source = await showDialog<ImageSource>(
                      context: context,
                      builder: (context) => const ImagePickerSheet(),
                    );
                    if (source != null) {
                      onPickImage(source);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                  ),
                  icon: Icon(Icons.add_a_photo, color: AppColors.white),
                )
              else
                const SizedBox(height: 48),
            ],
          ),
      ],
    );
  }
}
