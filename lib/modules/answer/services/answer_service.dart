import 'dart:async';
import 'dart:io';

import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/file_picker_service.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/notifications/repositories/notifications_repository.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/apis/upload_images_services.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AnswerService {
  // ... existing methods ...

  static Future<void> warmUpVideoCompress() async {
    if (PlatformService.platform == AppPlatform.androidApp) {
      return;
    }
    try {
      final byteData = await rootBundle.load('assets/images/start.MOV');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/start.MOV');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      await VideoCompress.compressVideo(
        tempFile.path,
        quality: VideoQuality.LowQuality,
      );

      await tempFile.delete();
    } catch (e) {
      debugPrint('Warm up failed: $e');
    }
  }

  static Future<String?> generateThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP,
      );

      if (thumbnail != null) {
        String fixedPath = thumbnail;
        if (!File(fixedPath).existsSync() && fixedPath.contains('%')) {
          try {
            fixedPath = Uri.decodeFull(fixedPath);
          } catch (e) {
            debugPrint('Error decoding thumbnail path: $e');
          }
        }
        return fixedPath;
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
    return null;
  }

  static Future<List<String>> uploadAnswerImages({
    required List<String> localImagePaths,
    required String questionId,
  }) async {
    List<String> urls = [];
    for (var k = 0; k < localImagePaths.length; k++) {
      final path = localImagePaths[k];
      final url = await UploadImagesToS3Api().uploadFiles(
        filePath: path,
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}_$k.png',
        destinationPath: 'answers/$questionId',
      );

      if (url.isNotEmpty) {
        urls.add(url);
      } else {
        throw Exception('Image upload failed');
      }
    }
    return urls;
  }

  static Future<String> uploadVideo({
    required String videoPath,
    required String questionId,
  }) async {
    final url = await UploadImagesToS3Api().uploadFiles(
      filePath: videoPath,
      fileName: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      destinationPath: 'answers/$questionId',
    );

    if (url.isEmpty) {
      throw Exception('Video upload failed');
    }
    return url;
  }

  static Future<String> uploadThumbnail({
    required String thumbnailPath,
    required String questionId,
  }) async {
    final url = await UploadImagesToS3Api().uploadFiles(
      filePath: thumbnailPath,
      fileName: 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.png',
      destinationPath: 'answers/$questionId',
    );

    if (url.isEmpty) {
      debugPrint('Thumbnail upload failed');
      return '';
    }
    return url;
  }

  static Future<void> sendMentionNotifications({
    required String text,
    required String questionId,
  }) async {
    final regex = RegExp(r'@([a-zA-Z0-9_.]+)');
    final matches = regex.allMatches(text);

    final usernames = matches.map((m) => m.group(1)!).toSet().toList();

    if (usernames.isEmpty) return;

    final response = await Supabase.instance.client
        .from('follows')
        .select('users:following_id!inner(id, token, username)')
        .eq('follower_id', MySharedPreferences.userId)
        .inFilter('users.username', usernames);

    final data = List<Map<String, dynamic>>.from(response);

    await Future.wait(
      data.map((item) async {
        final user = item['users'];
        final userId = user['id'];
        final token = user['token'];

        if (userId == MySharedPreferences.userId) return;

        await NotificationsRepository().sendNotification(
          senderId: MySharedPreferences.userId,
          receiverId: userId,
          type: AppConstance.mention,
          entityId: questionId,
          title: MySharedPreferences.userName,
          body: AppConstance.mentioned,
        );

        await SendMessageNotificationWithHTTPv1().send2(
          type: AppConstance.mention,
          urll: '',
          toToken: token,
          message: AppConstance.mentioned,
          title: MySharedPreferences.userName,
          id: questionId,
        );
      }),
    );
  }

  static Future<List<UserModel>> fetchUsersForMention(String query) async {
    final response = await Supabase.instance.client
        .from('follows')
        .select('users:following_id!inner(id, name, username, image)')
        .eq('follower_id', MySharedPreferences.userId)
        .ilike('users.username', '$query%')
        .limit(5);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => UserModel.fromMap(e['users'])).toList();
  }

  static Future<OverlayEntry> showMentionsOverlay({
    required BuildContext context,
    required List<UserModel> users,
    required LayerLink layerLink,
    required Function(UserModel) onUserSelected,
  }) async {
    final width =
        MediaQuery.of(context).size.width - (AppConstance.hPadding * 2);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 60.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.image.toString()),
                    radius: 15,
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    '@${user.userName}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () => onUserSelected(user),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String insertMention(
    String text,
    TextSelection selection,
    String username,
  ) {
    final textUpToCursor = text.substring(0, selection.baseOffset);
    final lastAtIndex = textUpToCursor.lastIndexOf('@');
    if (lastAtIndex != -1) {
      final before = text.substring(0, lastAtIndex);
      final after = text.substring(selection.baseOffset);
      return '$before@$username $after';
    }
    return text;
  }

  static Future<bool> showExitDialog(BuildContext context) async {
    return false;
  }

  static Future<QuestionModel> submitAnswer({
    required QuestionModel question,
    required String rawAnswerText,
    required String mediaType,
    required List<String> localImagePaths,
    String? localVideoPath,
    String? videoThumbnailPath,
    required bool isEditMode,
  }) async {
    List<String> uploadedImageUrls = [];
    String? uploadedVideoUrl;
    String? uploadedThumbnailUrl;

    /// 1️⃣ Upload Media
    bool shouldUploadImages =
        mediaType == 'image' && localImagePaths.isNotEmpty;
    bool shouldUploadVideo =
        mediaType == 'video' &&
        (localVideoPath != null || videoThumbnailPath != null);

    if (shouldUploadImages) {
      uploadedImageUrls = await uploadAnswerImages(
        localImagePaths: localImagePaths,
        questionId: question.id,
      );
    } else if (shouldUploadVideo) {
      await Future.wait([
        if (localVideoPath != null)
          uploadVideo(
            videoPath: localVideoPath,
            questionId: question.id,
          ).then((url) => uploadedVideoUrl = url),
        if (videoThumbnailPath != null)
          uploadThumbnail(
            thumbnailPath: videoThumbnailPath,
            questionId: question.id,
          ).then((url) => uploadedThumbnailUrl = url),
      ]);
    }

    /// 2️⃣ Process Mentions & Time
    final DateTime now = await getNetworkTime() ?? DateTime.now();
    String processedText = rawAnswerText.trim();

    // Process Mentions: Invalidate mentions of non-followed users
    final regex = RegExp(r'@([a-zA-Z0-9_.]+)');
    final matches = regex.allMatches(processedText).toList();

    if (matches.isNotEmpty) {
      final usernames = matches.map((m) => m.group(1)!).toSet().toList();
      if (usernames.isNotEmpty) {
        final response = await Supabase.instance.client
            .from('follows')
            .select('users:following_id!inner(username)')
            .eq('follower_id', MySharedPreferences.userId)
            .inFilter('users.username', usernames);

        final data = List<Map<String, dynamic>>.from(response);
        final validUsernames = data
            .map((e) => e['users']['username'] as String)
            .toSet();

        for (int i = matches.length - 1; i >= 0; i--) {
          final m = matches[i];
          final username = m.group(1)!;
          if (!validUsernames.contains(username)) {
            final start = m.start;
            final end = m.end;
            processedText = processedText.replaceRange(
              start,
              end,
              '@\u200B$username',
            );
          }
        }
      }
    }

    /// 3️⃣ Update Question in DB
    final Map<String, dynamic> updateData = {
      'answer_text': processedText,
      'is_edited': isEditMode,
    };

    if (!isEditMode) {
      updateData['answered_at'] = now.toUtc().toIso8601String();
    }

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
        .eq('id', question.id);

    /// 4️⃣ Notifications
    String usertokenIfisNotMe = '';
    final userResponse = await Supabase.instance.client
        .from('users')
        .select('token')
        .eq('id', question.sender.id)
        .maybeSingle();

    if (userResponse != null) {
      usertokenIfisNotMe = userResponse['token'] ?? '';
    }

    await Future.wait([
      NotificationsRepository().sendNotification(
        senderId: MySharedPreferences.userId,
        receiverId: question.sender.id,
        type: AppConstance.answer,
        entityId: question.id,
        title: MySharedPreferences.userName,
        body: AppConstance.asnwered,
      ),
      SendMessageNotificationWithHTTPv1().send2(
        type: AppConstance.answer,
        urll: '',
        toToken: usertokenIfisNotMe,
        message: AppConstance.asnwered,
        title: MySharedPreferences.userName,
        id: question.id,
      ),
      sendMentionNotifications(text: rawAnswerText, questionId: question.id),
    ]);

    /// 5️⃣ Return Updated Model
    return question.copyWith(
      answerText: updateData['answer_text'],
      isEdited: updateData['is_edited'],
      answeredAt: updateData.containsKey('answered_at')
          ? DateTime.parse(updateData['answered_at'])
          : null,
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
  }

  static Future<String?> pickImage({
    required BuildContext context,
    required ImageSource source,
    required bool isEditMode,
    required bool hasExistingMedia,
    required String currentMediaType, // mediaType
  }) async {
    // If in edit mode, prevent changing media ONLY IF media already exists
    if (isEditMode && hasExistingMedia) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Cannot change media when editing an answer'
            : 'لا يمكن تغيير المرفقات عند تعديل الإجابة',
      );
      return null;
    }

    if (currentMediaType == 'video') {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please remove video first'
            : 'يرجى حذف الفيديو أولاً',
      );
      return null;
    }

    try {
      final pickedFilePath = await ImagePickerService.pickFile(
        source: source,
        type: FileType.image,
      );

      return pickedFilePath;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> pickVideo({
    required BuildContext context,
    required ImageSource source,
    required bool isEditMode,
    required bool hasExistingMedia,
    required bool hasImages,
    required Function(String duration, String size) onInfoAvailable,
    required Function(String path) onThumbnailAvailable,
    required Function(double) onCompressionProgress,
    required Function(bool) onCompressionStatus,
  }) async {
    // If in edit mode, prevent changing media ONLY IF media already exists
    if (isEditMode && hasExistingMedia) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Cannot change media when editing an answer'
            : 'لا يمكن تغيير المرفقات عند تعديل الإجابة',
      );
      return null;
    }

    if (hasImages) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please remove images first'
            : 'يرجى حذف الصور أولاً',
      );
      return null;
    }

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

        onInfoAvailable(durationText, '${fileSizeInMB.toStringAsFixed(2)} MB');

        // Generate thumbnail immediately from original video
        final thumb = await generateThumbnail(video.path);
        if (thumb != null) {
          onThumbnailAvailable(thumb);
        }

        // Always compress video
        if (context.mounted) {
          AppConstance().showInfoToast(
            context,
            msg: !context.isCurrentLanguageAr()
                ? 'Compressing video...'
                : 'جاري ضغط الفيديو...',
          );
        }

        return await _processCompression(
          context: context,
          videoPath: video.path,
          originalSizeInMB: fileSizeInMB,
          onProgress: onCompressionProgress,
          onStatusChanged: onCompressionStatus,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppConstance().showErrorToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'Error picking video'
              : 'حدث خطأ أثناء اختيار الفيديو',
        );
      }
      debugPrint('Error picking video: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> _processCompression({
    required BuildContext context,
    required String videoPath,
    required double originalSizeInMB,
    required Function(double) onProgress,
    required Function(bool) onStatusChanged,
  }) async {
    final info = await compressVideo(
      path: videoPath,
      originalSizeInMB: originalSizeInMB,
      onProgress: onProgress,
      onStatusChanged: onStatusChanged,
    );

    if (info == null || info.path == null) {
      if (context.mounted) {
        AppConstance().showErrorToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'Video compression failed or file too large'
              : 'فشل ضغط الفيديو أو الملف كبير جداً',
        );
      }
      return null;
    }

    final compressedSize = info.filesize ?? 0;
    final compressedSizeInMB = compressedSize / (1024 * 1024);

    return {
      'path': info.path,
      'sizeText': '${compressedSizeInMB.toStringAsFixed(2)} MB',
    };
  }

  static Future<MediaInfo?> compressVideo({
    required String path,
    required double originalSizeInMB,
    required Function(double) onProgress,
    required Function(bool) onStatusChanged,
  }) async {
    try {
      await VideoCompress.deleteAllCache();

      onStatusChanged(true);
      onProgress(0.0);

      final subscription = VideoCompress.compressProgress$.subscribe((
        progress,
      ) {
        onProgress(progress);
      });

      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
      );

      subscription.unsubscribe();
      onStatusChanged(false);

      if (info != null && info.path != null) {
        final compressedSize = info.filesize ?? 0;
        final compressedSizeInMB = compressedSize / (1024 * 1024);

        debugPrint(
          'Original: ${originalSizeInMB.toStringAsFixed(2)} MB -> Compressed: ${compressedSizeInMB.toStringAsFixed(2)} MB',
        );

        if (compressedSizeInMB > 50) {
          debugPrint(
            'Compressed video still too large: ${compressedSizeInMB.toStringAsFixed(2)} MB',
          );
          return null;
        }

        return info;
      }

      return null;
    } catch (e) {
      onStatusChanged(false);
      debugPrint('Error compressing video: $e');
      return null;
    }
  }
}
