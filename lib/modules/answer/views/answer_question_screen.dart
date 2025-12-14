import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/file_picker_service.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
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

class AnswerQuestionScreen extends StatefulWidget {
  final QuestionModel question;
  const AnswerQuestionScreen({super.key, required this.question});

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFilePath = await ImagePickerService.pickFile(
        source: source,
        type: FileType.image,
      );

      if (pickedFilePath != null) {
        setState(() {
          localImagePaths.add(pickedFilePath);
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

    for (final path in localImagePaths) {
      final url = await UploadImagesToS3Api().uploadFiles(
        filePath: path,
        fileName: '${DateTime.now().millisecondsSinceEpoch}.png',
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

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  Future<void> sendQuestion() async {
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(context, msg: !context.isCurrentLanguageAr() ? 'No internet connection' : 'لا يوجد اتصال بالانترنت');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

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
      /// 1️⃣ رفع الصور
      uploadedImageUrls = await _uploadAnswerImages();

      /// 2️⃣ إرسال الجواب
      final docRef = FirebaseFirestore.instance
          .collection('questions')
          .doc(widget.question.id);
    DateTime now = await getNetworkTime() ?? DateTime.now();

      await docRef.update({
        'answeredAt': Timestamp.fromDate(now),
        'answerText': answerController.text.trim(),
        'images': uploadedImageUrls,
      });

      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Answered successfully'
            : 'تم إرسال الجواب بنجاح',
      );
      await SendMessageNotificationWithHTTPv1().send2(
        type: AppConstance.answer,
        urll: '',
        toToken: widget.question.sender.token,
        message: AppConstance.asnwered,
        title: 'Domandito',
        id: docRef.id,
      );

      context.backWithValue(true);
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

  // Future<void> sendQuestion() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => CustomDialog(
  //       title: 'تنبيه',
  //       content: 'هل تريد ارسال الجواب؟',

  //       onConfirm: () {},
  //     ),
  //   );
  //   if (confirmed == false) {
  //     return;
  //   }
  //   AppConstance().showLoading(context);

  //   setState(() {
  //     isSending = true;
  //   });

  //   try {
  //     final docRef = FirebaseFirestore.instance
  //         .collection('questions')
  //         .doc(widget.question.id);

  //     await docRef.update({
  //       'answeredAt': Timestamp.fromDate(now),
  //       'answerText': answerController.text.trim(),
  //       'images': answerImages,
  //     });

  //     AppConstance().showSuccesToast(context, msg: 'تم إرسال الجواب بنجاح');

  //     Loader.hide();
  //     context.backWithValue(true);
  //     // questionController.clear();
  //   } catch (e) {
  //     Loader.hide();
  //     AppConstance().showErrorToast(context, msg: 'حدث خطأ أثناء الإرسال');
  //   } finally {
  //     Loader.hide();

  //     setState(() {
  //       isSending = false;
  //     });
  //   }
  // }

  late QuestionModel question;

  @override
  void initState() {
    super.initState();

    /// إنشاء الموديل مرة واحدة فقط
    question = QuestionModel(
      id: widget.question.id,
      createdAt: Timestamp.now(),
      title: widget.question.title,
      sender: widget.question.sender,
      receiver: Receiver(
        token: MySharedPreferences.deviceToken,
        id: MySharedPreferences.userId,
        image: MySharedPreferences.image,
        name: MySharedPreferences.userName,
        userName: MySharedPreferences.userUserName,
      ),
      answerText: answerController.text.trim(),
      isLiked: true,
      likesCount: 10,
      isAnonymous: widget.question.isAnonymous,
    );
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
                  children: [
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
                    if (AppPlatform.unknown != platform &&
                        AppPlatform.webAndroid != platform &&
                        AppPlatform.webIOS != platform &&
                        AppPlatform.webDesktop != platform)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            !context.isCurrentLanguageAr()
                                ? 'Add images (optional)'
                                : 'إضافة صور (اختياري)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                                final source =
                                    await showModalBottomSheet<ImageSource>(
                                      useRootNavigator: true,
                                      routeSettings: const RouteSettings(
                                        name: 'ImagePickerSheet',
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                            AppConstance.radiusBig,
                                          ),
                                          topRight: Radius.circular(
                                            AppConstance.radiusBig,
                                          ),
                                        ),
                                      ),
                                      context: context,
                                      builder: (_) => const ImagePickerSheet(),
                                    );

                                if (source != null) {
                                  await _pickImage(source);
                                }
                              },
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  AppColors.primary,
                                ),
                              ),
                              icon: Icon(
                                Icons.add_a_photo,
                                color: AppColors.white,
                              ),
                            )
                          else
                            SizedBox(height: 48),
                        ],
                      ),
                    SizedBox(height: 10),
                    if (localImagePaths.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: localImagePaths.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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

                    // const SizedBox(height: 15),
                    const SizedBox(height: 15),
                  ],
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
}
