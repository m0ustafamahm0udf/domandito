import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/ask/models/q_model.dart';

import 'package:domandito/modules/question/views/like_list.dart';
import 'package:domandito/shared/models/report_model.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:domandito/shared/widgets/question_details_card.dart';
import 'package:domandito/shared/widgets/report_bottom_sheet.dart';
import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  final QuestionModel question;
  final String receiverImage;
  final String currentProfileUserId;
  final bool isVerified;
  final Function(QuestionModel) onBack;

  const QuestionScreen({
    super.key,
    required this.question,
    required this.receiverImage,
    required this.onBack,
    required this.currentProfileUserId,
    required this.isVerified,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 3. Privacy / Screenshot Check
    // Target is the Question Receiver (Answerer / Profile Owner)
    // We notify the person who posted the answer.
    // Privacy handled globally now
    // PrivacyServiceV6().enableSecureMode(
    //   context: context,
    //   targetUserId: widget.question.receiver.id,
    //   targetUserToken: widget.question.receiver.token,
    // );

    if (widget.question.answerText == null ||
        widget.question.answerText!.isEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        AppConstance().showInfoToast(
          context,
          msg: context.isCurrentLanguageAr()
              ? 'لا يوجد إجابة'
              : 'No answer found',
        );
        context.back();
      });
    }
  }

  @override
  void dispose() {
    // PrivacyServiceV6().disableSecureMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton.filled(
            onPressed: () => context.back(),
            icon: Icon(Icons.arrow_back),
          ),
          actions: [
            // ShareWidget(userUserName: '', questionId: widget.question.id),
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              onPressed: () {
                if (!MySharedPreferences.isLoggedIn) {
                  return;
                }
                showReportBottomSheet(
                  context: context,
                  contentId: widget.question.id,
                  contentType: ReportContentType.question,
                  contentOwnerId: widget.question.sender.id,
                );
              },
            ),

            SizedBox(width: 10),
          ],
        ),
        body: SafeArea(
          bottom: false,

          child: Stack(
            alignment: Alignment.center,
            children: [
              LogoWidg(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Column(
                  children: [
                    // CustomAppbar(
                    //   isBack: true,
                    //   isColored: true,
                    //    actions: IconButton.filled(
                    //             style: ButtonStyle(
                    //               backgroundColor: WidgetStatePropertyAll(
                    //                 AppColors.primary,
                    //               ),
                    //             ),
                    //             onPressed: () {
                    //               log('share');
                    //             },
                    //             icon: Icon(Icons.share, color: AppColors.white),
                    //           ),
                    //   // : () {
                    //   //   _handleBack().then((_) => Navigator.pop(context));
                    //   // },
                    // ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstance.hPaddingTiny - 5,
                        ),
                        children: [
                          QuestionDetailsCard(
                            currentProfileUserId: widget.currentProfileUserId,
                            isVerified: widget.isVerified,
                            displayName: widget.question.sender.name,
                            question: widget.question,
                            receiverImage: widget.receiverImage,
                          ),
                          if (widget.question.likesCount > 0)
                            LikesList(
                              questionId: widget.question.id,
                              question: widget.question,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
