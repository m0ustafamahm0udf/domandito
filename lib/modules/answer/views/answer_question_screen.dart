import 'dart:async';

import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/answer/services/answer_service.dart';
import 'package:domandito/modules/answer/views/widgets/answer_input_section.dart';
import 'package:domandito/modules/answer/views/widgets/compression_progress_section.dart';
import 'package:domandito/modules/answer/views/widgets/media_picker_section.dart';
import 'package:domandito/modules/answer/views/widgets/media_preview_section.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/answer_question_card_details.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

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
  double compressionProgress = 0.0;
  String? videoSizeText;
  String? videoDurationText;
  bool _forceExit = false;
  late QuestionModel question;

  @override
  void initState() {
    super.initState();
    AnswerService.warmUpVideoCompress();
    // Pre-fill answer text if in edit mode
    if (widget.answerText != null) {
      answerController.text = widget.answerText!;
      // Note: Media cannot be edited in edit mode
    }

    /// إنشاء الموديل مرة واحدة فقط
    question = widget.question.copyWith(isEdited: widget.answerText != null);
  }

  Future<bool> showExitDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: !context.isCurrentLanguageAr() ? 'Confirmation' : 'تنبيه',
        content: !context.isCurrentLanguageAr()
            ? 'Are you sure you want to exit?'
            : 'هل تريد الخروج؟',
        onConfirm: () {},
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFilePath = await AnswerService.pickImage(
      context: context,
      source: source,
      isEditMode: widget.answerText != null,
      hasExistingMedia:
          widget.question.images.isNotEmpty || widget.question.videoUrl != null,
      currentMediaType: mediaType,
    );

    if (pickedFilePath != null) {
      setState(() {
        localImagePaths.add(pickedFilePath);
        if (localImagePaths.isNotEmpty) {
          mediaType = 'image';
        }
      });
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    // Reset state before picking
    if (localVideoPath != null) {
      // Logic for cleaning up handled in service logic or implicitly
      localVideoPath = null;
      videoThumbnailPath = null;
      mediaType = 'none';
      setState(() {});
    }

    final result = await AnswerService.pickVideo(
      context: context,
      source: source,
      isEditMode: widget.answerText != null,
      hasExistingMedia:
          widget.question.images.isNotEmpty || widget.question.videoUrl != null,
      hasImages: localImagePaths.isNotEmpty,
      onInfoAvailable: (duration, size) {
        if (mounted) {
          setState(() {
            videoDurationText = duration;
            videoSizeText = size;
          });
        }
      },
      onThumbnailAvailable: (path) {
        if (mounted) {
          setState(() {
            videoThumbnailPath = path;
          });
        }
      },
      onCompressionProgress: (progress) {
        if (mounted) {
          setState(() {
            compressionProgress = progress;
          });
        }
      },
      onCompressionStatus: (status) {
        if (mounted) {
          setState(() {
            isCompressing = status;
          });
        }
      },
    );

    if (result != null) {
      setState(() {
        localVideoPath = result['path'];
        videoSizeText = result['sizeText'];
        originalVideoPath = null;
        mediaType = 'video';
      });
    }
  }

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _onTextChanged(String text) {
    setState(() {
      question.answerText = text;
    });

    final selection = answerController.selection;
    // Check if valid selection for autocomplete
    if (selection.baseOffset < 0) return;

    final textUpToCursor = text.substring(0, selection.baseOffset);

    // Regex to find the last @word sequence
    // We want to capture '@' and subsequent characters until cursor
    final match = RegExp(r'@([a-zA-Z0-9_.]*)$').firstMatch(textUpToCursor);

    if (match != null) {
      final query = match.group(1)!;
      // User requested "first two letters", so >= 2
      if (query.length >= 2) {
        _fetchAndShowMentions(query);
      } else {
        _removeOverlay();
      }
    } else {
      _removeOverlay();
    }
  }

  Future<void> _fetchAndShowMentions(String query) async {
    // Avoid error if widget unmounted
    if (!mounted) return;

    final users = await AnswerService.fetchUsersForMention(query);

    if (!mounted) {
      _removeOverlay();
      return;
    }

    if (users.isNotEmpty) {
      _showOverlay(users);
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay(List<UserModel> users) async {
    _removeOverlay();

    _overlayEntry = await AnswerService.showMentionsOverlay(
      context: context,
      users: users,
      layerLink: _layerLink,
      onUserSelected: _insertMention,
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _insertMention(UserModel user) {
    final text = answerController.text;
    final selection = answerController.selection;
    final textUpToCursor = text.substring(0, selection.baseOffset);

    // Find last @
    final lastAtIndex = textUpToCursor.lastIndexOf('@');
    if (lastAtIndex != -1) {
      final newText = AnswerService.insertMention(
        text,
        selection,
        user.userName,
      );

      answerController.text = newText;
      answerController.selection = TextSelection.collapsed(
        offset: lastAtIndex + user.userName.length + 2, // +2 for @ and space
      );
      // Trigger update
      setState(() {
        question.answerText = newText;
      });
    }
    _removeOverlay();
  }

  @override
  void dispose() {
    _removeOverlay();
    answerController.dispose();
    VideoCompress.cancelCompression(); // Fix: Cancel before deleting cache
    localVideoPath = null;
    videoThumbnailPath = null;
    mediaType = 'none';
    super.dispose();
  }

  Future<void> sendAnswer() async {
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
      final updatedQuestion = await AnswerService.submitAnswer(
        question: widget.question,
        rawAnswerText: answerController.text,
        mediaType: mediaType,
        localImagePaths: localImagePaths,
        localVideoPath: localVideoPath,
        videoThumbnailPath: videoThumbnailPath,
        isEditMode: widget.answerText != null,
      );

      Loader.hide();

      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Answered successfully'
            : 'تم إرسال الجواب بنجاح',
      );

      context.backWithValue(updatedQuestion);
    } catch (e) {
      Loader.hide();
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Error sending answer'
            : 'حدث خطأ أثناء الإرسال',
      );
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = PlatformService.platform;

    return PopScope(
      canPop:
          (answerController.text.isEmpty &&
              localImagePaths.isEmpty &&
              localVideoPath == null) ||
          _forceExit,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final confirmed = await showExitDialog();
        if (confirmed) {
          setState(() {
            _forceExit = true;
          });
          if (context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // title:  Text(widget.recipientName),
          leading: IconButton.filled(
            onPressed: () async {
              if (answerController.text.isEmpty &&
                  localImagePaths.isEmpty &&
                  localVideoPath == null) {
                context.back();
                return;
              }
              final confirmed = await showExitDialog();
              if (confirmed) {
                setState(() {
                  _forceExit = true;
                });
                if (context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pop();
                  });
                }
              }
            },
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
                    children: _body(context, platform),
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
                await sendAnswer();
              },
              title: !context.isCurrentLanguageAr() ? 'Answer' : 'جاوب',
              padding: 20,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, AppPlatform platform) {
    return [
      AnswerQuestionCardDetails(
        isInAnswerQuestionScreen: true,
        currentProfileUserId: MySharedPreferences.userId,
        question: question,
      ),
      const SizedBox(height: 20),
      AnswerInputSection(
        layerLink: _layerLink,
        controller: answerController,
        onTextChanged: _onTextChanged,
      ),
      const SizedBox(height: 30),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: const Divider(color: AppColors.primary, thickness: 0.3),
      ),
      const SizedBox(height: 20),
      if (AppPlatform.unknown != platform &&
          AppPlatform.webAndroid != platform &&
          AppPlatform.webIOS != platform &&
          AppPlatform.webDesktop != platform &&
          !isCompressing)
        MediaPickerSection(
          isEditMode: widget.answerText != null,
          hasExistingMedia:
              widget.question.images.isNotEmpty ||
              widget.question.videoUrl != null,
          isExistingVideo: widget.question.videoUrl != null,
          mediaType: mediaType,
          localImagesCount: localImagePaths.length,
          maxImages: maxImages,
          onPickImage: _pickImage,
          onPickVideo: _pickVideo,
        ),
      const SizedBox(height: 10),
      MediaPreviewSection(
        localImagePaths: localImagePaths,
        localVideoPath: localVideoPath,
        videoThumbnailPath: videoThumbnailPath,
        videoSizeText: videoSizeText,
        videoDurationText: videoDurationText,
        onRemoveImage: (index) {
          setState(() {
            localImagePaths.removeAt(index);
            if (localImagePaths.isEmpty) {
              mediaType = 'none';
            }
          });
        },
        onRemoveVideo: () {
          setState(() {
            localVideoPath = null;
            videoThumbnailPath = null;
            mediaType = 'none';
          });
        },
      ),
      CompressionProgressSection(
        isCompressing: isCompressing,
        compressionProgress: compressionProgress,
        onCancel: () {
          VideoCompress.cancelCompression();
          setState(() {
            isCompressing = false;
            localVideoPath = null;
            originalVideoPath = null;
            videoThumbnailPath = null;
            mediaType = 'none';
          });
        },
      ),
      const SizedBox(height: 15),
    ];
  }
}
