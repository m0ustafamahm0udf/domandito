import 'package:animate_do/animate_do.dart';
import 'package:domandito/modules/ask/services/ask_service.dart';
import 'package:domandito/modules/ask/views/widgets/anonymous_switch_section.dart';
import 'package:domandito/modules/ask/views/widgets/ask_floating_action_buttons.dart';
import 'package:domandito/modules/ask/views/widgets/ask_input_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'package:domandito/core/utils/extentions.dart';

import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/ask_question_details_card.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
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

    await AskService.sendQuestion(
      context: context,
      questionText: questionController.text,
      isAnonymous: isAnonymous,
      recipientToken: widget.recipientToken,
      recipientName: widget.recipientName,
      recipientUserName: widget.recipientUserName,
      recipientId: widget.recipientId,
      recipientImage: widget.recipientImage,
      onSuccess: () {
        Loader.hide();
        context.backWithValue(true);
        setState(() {
          isSending = false;
        });
      },
      onError: () {
        Loader.hide();
        setState(() {
          isSending = false;
        });
      },
    );
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
                      FadeIn(
                        key: Key(question.sender.image.toString()),
                        child: AskQuestionDetailsCard(
                          currentProfileUserId: MySharedPreferences.userId,
                          displayName: '',
                          isVerified: widget.isVerified,
                          question: question,
                          receiverImage: widget.recipientImage,
                        ),
                      ),
                      const SizedBox(height: 20),

                      AskInputSection(
                        controller: questionController,
                        onChanged: (s) {
                          setState(() {
                            question.title = s;
                          });
                        },
                      ),

                      // const SizedBox(height: 15),
                      AnonymousSwitchSection(
                        isAnonymous: isAnonymous,
                        canAskedAnonymously: widget.canAskedAnonymously,
                        recipientName: widget.recipientName,
                        isRandomLoading: isRandomLoading,
                        onChanged: (value) {
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
        floatingActionButton: AskFloatingActionButtons(
          isRandomLoading: isRandomLoading,
          onAskPressed: () async {
            await sendQuestion();
          },
          onRandomPressed: fetchRandomQuestion,
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
