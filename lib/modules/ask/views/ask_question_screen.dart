import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';

import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';

import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/ask_question_details_card.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class AskQuestionScreen extends StatefulWidget {
  final bool isVerified;
  final bool canAskedAnonymously;
  final String recipientName;
  final String recipientUserName;
  final String recipientId;
  final String recipientToken;
  final String recipientImage;
  const AskQuestionScreen({
    super.key,
    required this.recipientName,
    required this.recipientId,
    required this.recipientImage,
    required this.isVerified,
    required this.recipientUserName,
    required this.recipientToken,
    required this.canAskedAnonymously,
  });

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final TextEditingController questionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isSending = false;
  bool _forceExit = false;

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  bool isAnonymous = false;

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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: !context.isCurrentLanguageAr() ? 'Confirmation' : 'تنبيه',
        content: !context.isCurrentLanguageAr()
            ? 'Are you sure you want to ask the question?'
            : 'هل تريد ارسال السؤال؟',

        onConfirm: () {},
      ),
    );
    if (confirmed == false) {
      return;
    }
    AppConstance().showLoading(context);
    setState(() {
      isSending = true;
    });

    try {
      final String questionId = const Uuid().v4();
      DateTime now = await getNetworkTime() ?? DateTime.now();
      // log(now.toString() + 'now');
      final question = QuestionModel(
        id: questionId,
        createdAt: now.toUtc(),
        // answeredAt: Timestamp.fromDate(
        //   Timestamp.now().toDate().add(const Duration(minutes: 1)),
        // ),
        title: questionController.text.trim(),
        sender: Sender(
          token: MySharedPreferences.deviceToken,
          userName: MySharedPreferences.userUserName,
          id: MySharedPreferences.userId,
          name: MySharedPreferences.userName,
          image: MySharedPreferences.image,
        ),
        // answerText: 'هنا الاجابه الاجابه الاجابه الاجابه الاجابه الاجابه تيست',
        isDeleted: false,
        images: [], // لو هتضيف صور ارسلها هنا
        isAnonymous: isAnonymous,
        likesCount: 0,
        commentCount: 0,
        receiver: Receiver(
          token: widget.recipientToken,
          name: widget.recipientName,
          userName: widget.recipientUserName,
          id: widget.recipientId,
          image: widget.recipientImage,
        ),
      );

      // Insert into Supabase
      // toJson returns sender_id and receiver_id which matches the table
      // We explicitly pass 'id' here if we want to use the generated UUID for notifications, otherwise we'd let DB gen it and return it.
      // Since we need the ID for notification below, we'll send it.
      var data = question.toJson();
      data['id'] = questionId; // Explicitly set ID

      await Supabase.instance.client.from('questions').insert(data);
      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Question sent successfully'
            : 'تم إرسال السؤال بنجاح',
      );

      // log('Attempting to send notifications...');
      try {
        // Send persistent notification and push notification in parallel
        // Send push notification only
        await SendMessageNotificationWithHTTPv1().send2(
          type: AppConstance.question,
          urll: '',
          toToken: widget.recipientToken,
          message: AppConstance.questioned,
          title: isAnonymous
              ? (!context.isCurrentLanguageAr() ? 'Anonymous' : 'مجهول')
              : MySharedPreferences.userName,
          id: questionId,
        );
        // .then((_) => log('Push notification sent successfully'));
        // log('All notifications sent.');
      } catch (e, _) {
        // log(
        //   'Error sending notifications: $e\n$stack',
        //   error: e,
        //   stackTrace: stack,
        // );
      }
      // log(questionId + 'questionId');

      Loader.hide();

      context.backWithValue(true);
      // questionController.clear();
    } catch (e) {
      Loader.hide();
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Something went wrong'
            : 'حدث خطأ أثناء الإرسال',
      );
    } finally {
      Loader.hide();

      setState(() {
        isSending = false;
      });
    }
  }

  late QuestionModel question;

  @override
  void initState() {
    super.initState();

    /// إنشاء الموديل مرة واحدة فقط
    question = QuestionModel(
      id: '',
      createdAt: DateTime.now(),
      title: '',
      sender: Sender(
        token: MySharedPreferences.deviceToken,
        id: MySharedPreferences.userId,
        name: MySharedPreferences.userName,
        userName: MySharedPreferences.userUserName,
        image: MySharedPreferences.image,
        isVerified: MySharedPreferences.isVerified,
      ),
      receiver: Receiver(
        token: widget.recipientToken,
        id: widget.recipientId,
        image: widget.recipientImage,
        userName: widget.recipientUserName,
        name: widget.recipientName,
      ),
      answerText: '',
      isLiked: true,
      likesCount: 10,
      isAnonymous: isAnonymous,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: questionController.text.isEmpty || _forceExit,
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.recipientName),
              if (widget.isVerified)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SvgPicture.asset(
                    AppIcons.verified,
                    height: 18,
                    width: 18,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          leading: IconButton.filled(
            onPressed: () async {
              if (questionController.text.isEmpty) {
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
              // CustomAppbar(
              //   isBack: true,
              //   preTitle: 'سؤال لـ',
              //   // title: 'سؤال',
              //   isColored: true,
              //   title: widget.recipientName,
              //   // actions: Transform.translate(
              //   //   offset: const Offset(5, -5),
              //   //   child: CustomNetworkImage(
              //   //     url: widget.recipientImage,
              //   //     radius: 999,
              //   //     height: 35,
              //   //     width: 35,
              //   //   ),
              //   // ),
              // ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.only(
                      right: AppConstance.vPadding,
                      left: AppConstance.vPadding,
                      top: AppConstance.hPadding,
                      bottom: AppConstance.hPaddingBig * 15,
                    ),
                    children: [
                      // Text(
                      // const SizedBox(height: 20),
                      FadeIn(
                        key: Key(question.sender.image.toString()),
                        child: AskQuestionDetailsCard(
                          currentProfileUserId: MySharedPreferences.userId,

                          displayName: '',
                          isVerified: widget.isVerified,
                          // isInAskQuestionScreen: true,
                          // // isInQuestionScreen: true,
                          // isInProfileScreen: false,
                          question: question,
                          receiverImage: widget.recipientImage,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        // autoFocus: true,
                        onChanged: (s) {
                          setState(() {
                            question.title = s;
                          });
                        },
                        //  hintStyle: TextStyle(fontSize: 18),
                        style: TextStyle(fontSize: 16),
                        controller: questionController,
                        textInputAction: TextInputAction.newline,
                        minLines: 2,
                        maxLines: 5,
                        hintText: !context.isCurrentLanguageAr()
                            ? 'Ask a question'
                            : 'سؤالك هنا',
                        lenght: 350,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '';
                          }
                          if (value.length > 350) {
                            return !context.isCurrentLanguageAr()
                                ? 'Question must be less than 350 characters'
                                : 'السؤال يجب أن يكون أقل من 350 حرف';
                          }
                          if (containsBannedWords(value)) {
                            return !context.isCurrentLanguageAr()
                                ? 'Your question contains prohibited words'
                                : 'السؤال يحتوي على كلمات ممنوعة';
                          }
                          return null;
                        },
                      ),

                      // const SizedBox(height: 15),
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        value: isAnonymous,
                        onChanged: (value) {
                          if (isRandomLoading) return;
                          if (!widget.canAskedAnonymously) {
                            AppConstance().showInfoToast(
                              context,
                              msg: !context.isCurrentLanguageAr()
                                  ? '"${widget.recipientName}" prevens asking anonymously'
                                  : '"${widget.recipientName}" لا يسمح بهذه الخاصية',
                            );
                            return;
                          }
                          setState(() {
                            isAnonymous = value;

                            /// تحديث sender في الكارد
                            question.sender = Sender(
                              token: MySharedPreferences.deviceToken,
                              id: MySharedPreferences.userId,
                              name: value
                                  ? !context.isCurrentLanguageAr()
                                        ? 'Anonymous'
                                        : 'مجهول'
                                  : MySharedPreferences.userName,
                              userName: value
                                  ? 'x'
                                  : MySharedPreferences.userUserName,
                              image: value
                                  ? 'https://takeawayapp.ams3.digitaloceanspaces.com/play_store_512.png'
                                  : MySharedPreferences.image,
                            );
                          });
                        },
                        title: Text(
                          !context.isCurrentLanguageAr()
                              ? 'Anonymous'
                              : 'مجهول',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
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
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: BounceButton(
                radius: 60,
                height: 55,
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () async {
                  if (isRandomLoading) return;
                  await sendQuestion();
                },
                title: !context.isCurrentLanguageAr() ? 'Ask' : 'إسأل',
                padding: 20,
              ),
            ),

            // const SizedBox(width: 5),
            GestureDetector(
              onTap: isRandomLoading ? null : fetchRandomQuestion,
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: isRandomLoading
                    ? const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: CupertinoActivityIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.casino, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  bool isRandomLoading = false;

  Future<void> fetchRandomQuestion() async {
    setState(() {
      isRandomLoading = true;
    });
    try {
      final response = await Supabase.instance.client.rpc(
        'get_random_question',
      );

      if (response != null && (response as List).isNotEmpty) {
        final data = response[0];
        final text = data['question_text'].toString().trim();

        // Clear current text
        questionController.clear();
        setState(() {
          question.title = '';
        });

        // Typewriter animation
        for (int i = 0; i < text.length; i++) {
          if (!mounted) return;
          await Future.delayed(const Duration(milliseconds: 25));
          if (!mounted) return;

          setState(() {
            questionController.text += text[i];
            // Move cursor to end
            questionController.selection = TextSelection.fromPosition(
              TextPosition(offset: questionController.text.length),
            );
            question.title = questionController.text;
          });
        }
      }
    } catch (e) {
      // log('Error fetching random question: $e');
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Failed to get random question'
            : 'فشل في جلب سؤال عشوائي',
      );
    } finally {
      setState(() {
        isRandomLoading = false;
      });
    }
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
}
