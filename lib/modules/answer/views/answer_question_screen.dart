import 'dart:async';
import 'dart:io';

import 'package:domandito/core/constants/app_icons.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/file_picker_service.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/notifications/repositories/notifications_repository.dart';
import 'package:domandito/shared/apis/upload_images_services.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/answer_question_card_details.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:domandito/shared/widgets/show_image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class AnswerQuestionScreen extends StatefulWidget {
  final QuestionModel question;
  final String? answerText; // If provided, user is in edit mode

  const AnswerQuestionScreen({
    super.key,
    required this.question,
    this.answerText,
  });

  @override
  State<AnswerQuestionScreen> createState() => _AnswerQuestionScreenState();
}

class _AnswerQuestionScreenState extends State<AnswerQuestionScreen> {
  final TextEditingController answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isSending = false;
  // List<String> answerImages = [];
  static const int maxImages = 4;
  List<String> localImagePaths = [];
  List<String> uploadedImageUrls = [];

  // Video state
  String? localVideoPath;
  String? originalVideoPath; // Store original video before compression
  String? uploadedVideoUrl;
  String? uploadedThumbnailUrl; // Added
  String? videoThumbnailPath;
  String mediaType = 'none'; // 'none', 'image', 'video'
  bool isCompressing = false;
  // bool useIndeterminateProgress = false; // Fallback when progress stuck at 0%
  double compressionProgress = 0.0;
  String? videoSizeText;
  String? videoDurationText;

  Future<void> _pickImage(ImageSource source) async {
    // If in edit mode, prevent changing media
    // If in edit mode, prevent changing media ONLY IF media already exists
    if (widget.answerText != null &&
        (widget.question.images.isNotEmpty ||
            widget.question.videoUrl != null)) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Cannot change media when editing an answer'
            : 'لا يمكن تغيير المرفقات عند تعديل الإجابة',
      );
      return;
    }

    if (mediaType == 'video') {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please remove video first'
            : 'يرجى حذف الفيديو أولاً',
      );
      return;
    }

    try {
      final pickedFilePath = await ImagePickerService.pickFile(
        source: source,
        type: FileType.image,
      );

      if (pickedFilePath != null) {
        setState(() {
          localImagePaths.add(pickedFilePath);
          if (localImagePaths.isNotEmpty) {
            mediaType = 'image';
          }
        });
      }
    } catch (e) {
      // AppConstance().showErrorToast(
      //   context,
      //   msg: 'حدث خطأ أثناء اختيار الصورة',
      // );
    }
  }

  Future<List<String>> _uploadAnswerImages() async {
    List<String> urls = [];
    for (var k = 0; k < localImagePaths.length; k++) {
      final path = localImagePaths[k];
      final url = await UploadImagesToS3Api().uploadFiles(
        filePath: path,
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}_$k.png',
        destinationPath: 'answers/${widget.question.id}',
      );

      if (url.isNotEmpty) {
        urls.add(url);
      } else {
        throw Exception('Image upload failed');
      }
    }
    return urls;
  }

  Future<String> _uploadThumbnail() async {
    if (videoThumbnailPath == null) return '';

    final url = await UploadImagesToS3Api().uploadFiles(
      filePath: videoThumbnailPath!,
      fileName: 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.png',
      destinationPath: 'answers/${widget.question.id}',
    );

    if (url.isEmpty) {
      debugPrint('Thumbnail upload failed');
      return '';
    }

    return url;
  }

  Future<void> _pickVideo(ImageSource source) async {
    // If in edit mode, prevent changing media
    // If in edit mode, prevent changing media ONLY IF media already exists
    if (widget.answerText != null &&
        (widget.question.images.isNotEmpty ||
            widget.question.videoUrl != null)) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Cannot change media when editing an answer'
            : 'لا يمكن تغيير المرفقات عند تعديل الإجابة',
      );
      return;
    }

    if (localImagePaths.isNotEmpty) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please remove images first'
            : 'يرجى حذف الصور أولاً',
      );
      return;
    }
    localVideoPath = null;
    videoThumbnailPath = null;
    mediaType = 'none';

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: source);

      if (video != null) {
        final file = File(video.path);
        final fileSize = await file.length();
        final fileSizeInMB = fileSize / (1024 * 1024);

        // Get video duration
        final info = await VideoCompress.getMediaInfo(video.path);
        final duration = info.duration ?? 0;
        final durationInSeconds = duration / 1000;
        final minutes = (durationInSeconds / 60).floor();
        final seconds = (durationInSeconds % 60).floor();
        final durationText =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        setState(() {
          videoSizeText = '${fileSizeInMB.toStringAsFixed(2)} MB';
          videoDurationText = durationText;
        });

        // Generate thumbnail immediately from original video
        await _generateThumbnail(video.path);

        // Always compress video
        AppConstance().showInfoToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'Compressing video...'
              : 'جاري ضغط الفيديو...',
        );
        localVideoPath = null;
        originalVideoPath = null;

        var compressedPath = await _compressVideo(
          video.path,
          originalSizeInMB: fileSizeInMB,
        );

        if (compressedPath == null) {
          // Compression failed or exceeded limit even after compression
          // Reset state
          setState(() {
            localVideoPath = null;
            originalVideoPath = null;
          });

          if (isCompressing == false) {
            // Manual cancellation, do nothing
          } else {
            AppConstance().showErrorToast(
              context,
              msg: !context.isCurrentLanguageAr()
                  ? 'Video compression failed or file too large'
                  : 'فشل ضغط الفيديو أو الملف كبير جداً',
            );
          }
          return;
        }

        setState(() {
          localVideoPath = compressedPath;
          originalVideoPath = null;
          mediaType = 'video';
        });
      }
    } catch (e) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Error picking video'
            : 'حدث خطأ أثناء اختيار الفيديو',
      );
      debugPrint('Error picking video: $e');
    }
  }

  Future<String?> _compressVideo(
    String path, {
    required double originalSizeInMB,
  }) async {
    // Timer? fallbackTimer;
    try {
      // Clear any cached video from previous compression attempts
      await VideoCompress.deleteAllCache();

      setState(() {
        isCompressing = true;
        compressionProgress = 0.0;
        // useIndeterminateProgress = false;
      });

      final subscription = VideoCompress.compressProgress$.subscribe((
        progress,
      ) {
        if (mounted) {
          setState(() {
            compressionProgress = progress;
            // If we receive actual progress, disable indeterminate mode
            if (progress > 0) {
              // useIndeterminateProgress = false;
            }
          });
        }
      });

      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
      );

      subscription.unsubscribe();

      if (!mounted || !isCompressing) {
        return null;
      }

      setState(() {
        isCompressing = false;
      });

      if (info != null && info.path != null) {
        final compressedSize = info.filesize ?? 0;
        final compressedSizeInMB = compressedSize / (1024 * 1024);

        // Log compression results for debugging
        debugPrint(
          'Original: ${originalSizeInMB.toStringAsFixed(2)} MB -> Compressed: ${compressedSizeInMB.toStringAsFixed(2)} MB',
        );

        setState(() {
          videoSizeText = '${compressedSizeInMB.toStringAsFixed(2)} MB';
        });

        if (compressedSizeInMB > 50) {
          debugPrint(
            'Compressed video still too large: ${compressedSizeInMB.toStringAsFixed(2)} MB',
          );
          return null;
        }

        return info.path;
      }

      return null;
    } catch (e) {
      if (mounted) {
        setState(() {
          isCompressing = false;
        });
      }
      debugPrint('Error compressing video: $e');
      return null;
    }
  }

  Future<void> _generateThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP, // Changed to JPEG for better reliability
        // quality: 75,
      );

      if (thumbnail != null) {
        // Fix for iOS paths that might be URL encoded (e.g. %20 instead of space)
        String fixedPath = thumbnail;
        if (!File(fixedPath).existsSync() && fixedPath.contains('%')) {
          try {
            fixedPath = Uri.decodeFull(fixedPath);
          } catch (e) {
            debugPrint('Error decoding thumbnail path: $e');
          }
        }

        setState(() {
          videoThumbnailPath = fixedPath;
        });
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
  }

  Future<String> _uploadVideo() async {
    if (localVideoPath == null) return '';

    final url = await UploadImagesToS3Api().uploadFiles(
      filePath: localVideoPath!,
      fileName: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      destinationPath: 'answers/${widget.question.id}',
    );

    if (url.isEmpty) {
      throw Exception('Video upload failed');
    }

    return url;
  }

  @override
  void dispose() {
    answerController.dispose();
    VideoCompress.cancelCompression(); // Fix: Cancel before deleting cache
    localVideoPath = null;
    videoThumbnailPath = null;
    mediaType = 'none';
    super.dispose();
  }

  Future<void> sendQuestion() async {
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (isCompressing) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please wait for video compression to finish'
            : 'يرجى الانتظار حتى ينتهي ضغط الفيديو',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CustomDialog(
        title: !context.isCurrentLanguageAr() ? 'Confirmation' : 'تنبيه',
        content: !context.isCurrentLanguageAr()
            ? 'Are you sure you want to answer?'
            : 'هل تريد ارسال الجواب؟',
        onConfirm: () {},
      ),
    );

    if (confirmed != true) return;

    AppConstance().showLoading(context);
    setState(() => isSending = true);

    try {
      /// 1️⃣ رفع الصور أو الفيديو

      // Determine if we should attempt upload:
      // - New answer (answerText == null)
      // - OR Edit mode but adding NEW media (when original was empty)
      bool shouldUploadImages =
          mediaType == 'image' && localImagePaths.isNotEmpty;
      bool shouldUploadVideo =
          mediaType == 'video' &&
          (localVideoPath != null || videoThumbnailPath != null);

      if (shouldUploadImages) {
        uploadedImageUrls = await _uploadAnswerImages();
      } else if (shouldUploadVideo) {
        // Upload video AND thumbnail
        await Future.wait([
          if (localVideoPath != null)
            _uploadVideo().then((url) => uploadedVideoUrl = url),
          if (videoThumbnailPath != null)
            _uploadThumbnail().then((url) => uploadedThumbnailUrl = url),
        ]);
      }

      /// 2️⃣ إرسال الجواب
      final DateTime now = await getNetworkTime() ?? DateTime.now();

      final Map<String, dynamic> updateData = {
        'answer_text': answerController.text.trim(),
        'is_edited': widget.answerText != null, // Set true if editing
      };

      // Only set answered_at if it's a NEW answer
      if (widget.answerText == null) {
        updateData['answered_at'] = now.toUtc().toIso8601String();
      }

      // Handle media fields update
      if (shouldUploadImages) {
        updateData['images'] = uploadedImageUrls;
        updateData['media_type'] = 'image';
      } else if (shouldUploadVideo) {
        if (uploadedVideoUrl != null) {
          updateData['video_url'] = uploadedVideoUrl;
        }
        if (uploadedThumbnailUrl != null) {
          updateData['thumbnail_url'] = uploadedThumbnailUrl;
        }
        updateData['media_type'] = 'video';
      }

      await Supabase.instance.client
          .from('questions')
          .update(updateData)
          .eq('id', widget.question.id);

      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Answered successfully'
            : 'تم إرسال الجواب بنجاح',
      );
      String usertokenIfisNotMe = '';

      final userResponse = await Supabase.instance.client
          .from('users')
          .select('token')
          .eq('id', widget.question.sender.id)
          .maybeSingle();

      if (userResponse != null) {
        usertokenIfisNotMe = userResponse['token'] ?? '';
      }

      // Send persistent notification and push notification in parallel
      await Future.wait([
        NotificationsRepository().sendNotification(
          senderId: MySharedPreferences.userId,
          receiverId: widget.question.sender.id,
          type: AppConstance.answer,
          entityId: widget.question.id,
          title: MySharedPreferences.userName,
          body: AppConstance.asnwered,
        ),
        SendMessageNotificationWithHTTPv1().send2(
          type: AppConstance.answer,
          urll: '',
          toToken: usertokenIfisNotMe,
          message: AppConstance.asnwered,
          title: MySharedPreferences.userName,
          id: widget.question.id,
        ),
      ]);

      // Update local question model to return it using copyWith (immutable update)
      final updatedQuestion = question.copyWith(
        answerText: updateData['answer_text'],
        isEdited: updateData['is_edited'],
        answeredAt: updateData.containsKey('answered_at')
            ? DateTime.parse(updateData['answered_at'])
            : null, // If not updated, copyWith keeps original
        images: updateData.containsKey('images')
            ? List<String>.from(updateData['images'])
            : null,
        videoUrl: updateData.containsKey('video_url')
            ? updateData['video_url']
            : null,
        thumbnailUrl: updateData.containsKey('thumbnail_url')
            ? updateData['thumbnail_url']
            : null,
        mediaType: updateData.containsKey('media_type')
            ? updateData['media_type']
            : null,
      );

      context.backWithValue(updatedQuestion);
    } catch (e) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Error sending answer'
            : 'حدث خطأ أثناء الإرسال',
      );
    } finally {
      Loader.hide();
      setState(() => isSending = false);
    }
  }

  late QuestionModel question;

  Future<void> _warmUpVideoCompress() async {
    if (PlatformService.platform == AppPlatform.androidApp) {
      return;
    }
    try {
      // Copy asset to temp file
      final byteData = await rootBundle.load('assets/images/start.MOV');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/start.MOV');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Warm up the encoder
      await VideoCompress.compressVideo(
        tempFile.path,
        quality: VideoQuality.LowQuality,
      );

      // Delete temp file
      await tempFile.delete();
    } catch (e) {
      debugPrint('Warm up failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _warmUpVideoCompress();

    // Pre-fill answer text if in edit mode
    if (widget.answerText != null) {
      answerController.text = widget.answerText!;
      // Note: Media cannot be edited in edit mode
    }

    /// إنشاء الموديل مرة واحدة فقط
    /// Initialize question from widget.question preserving all data (images, video, etc.)
    question = widget.question.copyWith(isEdited: widget.answerText != null);
  }

  @override
  Widget build(BuildContext context) {
    final platform = PlatformService.platform;

    return Scaffold(
      appBar: AppBar(
        // title:  Text(widget.recipientName),
        leading: IconButton.filled(
          onPressed: () => context.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // CustomAppbar(isBack: true, isColored: true),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: AppConstance.vPadding,
                    left: AppConstance.vPadding,
                    top: AppConstance.hPadding,
                    bottom: AppConstance.hPaddingBig * 15,
                  ),
                  children: _mediaTypes(context, platform),
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 15),

          BounceButton(
            radius: 60,
            height: 55,
            gradient: LinearGradient(
              colors: [AppColors.primary, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onPressed: () async {
              await sendQuestion();
            },
            title: !context.isCurrentLanguageAr() ? 'Answer' : 'جاوب',
            padding: 20,
          ),
        ],
      ),
    );
  }

  List<Widget> _mediaTypes(BuildContext context, AppPlatform platform) {
    return [
      // Text(
      // const SizedBox(height: 20),
      AnswerQuestionCardDetails(
        isInAnswerQuestionScreen: true,
        currentProfileUserId: MySharedPreferences.userId,

        question: question,
      ),
      const SizedBox(height: 20),
      CustomTextField(
        onChanged: (s) {
          setState(() {
            question.answerText = s;
          });
        },
        //  hintStyle: TextStyle(fontSize: 18),
        style: TextStyle(fontSize: 20),
        // autoFocus: true,
        controller: answerController,
        textInputAction: TextInputAction.newline,
        minLines: 2,
        maxLines: 5,
        hintText: !context.isCurrentLanguageAr()
            ? 'Write your answer here'
            : 'إجابتك هنا',
        lenght: 350,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '';
          }
          if (value.length > 350) {
            return !context.isCurrentLanguageAr()
                ? 'Answer must be less than 350 characters'
                : 'الإجابة يجب أن تكون أقل من 350 حرف';
          }
          return null;
        },
      ),
      const SizedBox(height: 30),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Divider(color: AppColors.primary, thickness: 0.3),
      ),
      const SizedBox(height: 20),

      if (AppPlatform.unknown != platform &&
          AppPlatform.webAndroid != platform &&
          AppPlatform.webIOS != platform &&
          AppPlatform.webDesktop != platform &&
          !isCompressing) ...[
        // If in edit mode and media exists, show message instead of picker
        if (widget.answerText != null &&
            (widget.question.images.isNotEmpty ||
                widget.question.videoUrl != null))
          Container(
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
                  widget.question.videoUrl != null
                      ? Icons.videocam
                      : Icons.image,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.question.videoUrl != null
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
          )
        else if (mediaType == 'none')
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
                        await _pickImage(source);
                      }
                    },
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          AppIcons.addImage,
                          height: 40,
                          // color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          !context.isCurrentLanguageAr()
                              ? 'Add images'
                              : 'إضافة صور',
                          style: TextStyle(
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
                  // width: 20,
                  height: 40,
                  child: VerticalDivider(
                    color: AppColors.primary,
                    thickness: 0.3,
                  ),
                ),
                // Text(
                //   !context.isCurrentLanguageAr() ? 'OR' : 'أو',
                //   style: const TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: AppColors.primary,
                //   ),
                // ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final ImageSource? source = await showDialog<ImageSource>(
                        context: context,
                        builder: (context) => const ImagePickerSheet(),
                      );
                      if (source != null) {
                        await _pickVideo(source);
                      }
                    },
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          AppIcons.video,
                          height: 40,
                          // color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          !context.isCurrentLanguageAr()
                              ? 'Add video'
                              : 'إضافة فيديو',
                          style: TextStyle(
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
              // Text(
              //   !context.isCurrentLanguageAr()
              //       ? 'Add images (optional)'
              //       : 'إضافة صور (اختياري)',
              //   style: const TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              if (localImagePaths.length < maxImages)
                IconButton(
                  onPressed: () async {
                    if (localImagePaths.length >= maxImages) {
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
                      await _pickImage(source);
                    }
                  },
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                  ),
                  icon: Icon(Icons.add_a_photo, color: AppColors.white),
                )
              else
                const SizedBox(height: 48),
            ],
          ),
      ],
      SizedBox(height: 10),
      if (localImagePaths.isNotEmpty)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: localImagePaths.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 2 × 2 = 4 صور
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
                    onTap: () {
                      setState(() {
                        localImagePaths.removeAt(index);
                        if (localImagePaths.isEmpty) {
                          mediaType = 'none';
                        }
                      });
                    },
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

      SizedBox(height: 10),

      // Video preview
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
            // Play icon overlay
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
            // Size and Duration Overlay
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    localVideoPath = null;
                    videoThumbnailPath = null;
                    mediaType = 'none';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),

      // Compression progress
      if (isCompressing)
        Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    // Use null for indeterminate, or actual value for determinate
                    value: compressionProgress / 100,
                    backgroundColor: Colors.grey[300],
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    VideoCompress.cancelCompression();
                    setState(() {
                      isCompressing = false;
                      localVideoPath = null;
                      originalVideoPath = null;
                      videoThumbnailPath = null;
                      mediaType = 'none';
                    });
                  },
                  child: Text(
                    !context.isCurrentLanguageAr() ? 'Cancel' : 'إلغاء',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              (!context.isCurrentLanguageAr()
                  ? 'Compressing: ${compressionProgress.toStringAsFixed(0)}%'
                  : 'جاري الضغط: ${compressionProgress.toStringAsFixed(0)}%'),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

      const SizedBox(height: 15),
    ];
  }
}
