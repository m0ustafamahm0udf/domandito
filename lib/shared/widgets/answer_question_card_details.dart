import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/answer/views/answer_question_screen.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg_flutter.dart';

class AnswerQuestionCardDetails extends StatefulWidget {
  final QuestionModel question;
  // final String receiverImage;
  // final bool isInProfileScreen;
  // final bool isInQuestionScreen;
  final bool isInAnswerQuestionScreen;
  // final bool isInAskQuestionScreen;
  final String currentProfileUserId;
  final Function()? afterBack;

  const AnswerQuestionCardDetails({
    super.key,
    required this.question,

    required this.currentProfileUserId,
    this.afterBack,
    required this.isInAnswerQuestionScreen,
  });

  @override
  State<AnswerQuestionCardDetails> createState() =>
      _AnswerQuestionCardDetailsState();
}

class _AnswerQuestionCardDetailsState extends State<AnswerQuestionCardDetails> {
  @override
  void initState() {
    super.initState();
    question = widget.question; // نسخة داخلية
  }

  late QuestionModel question;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '${question.id}answer',
      child: GestureDetector(
        onTap: () {
          if (question.answerText == null) {
            pushScreen(
              context,
              screen: AnswerQuestionScreen(question: question),
            ).then((value) {
              if (value == true) {
                if (widget.afterBack != null) {
                  // log('after back');

                  widget.afterBack!();
                }
              }
            });
            return;
          }
        },
        child: Card(
          color: AppColors.white,
          elevation: 20,

          shadowColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstance.hPadding,
              vertical: AppConstance.vPaddingTiny,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                GestureDetector(
                  onTap: () {
                    if (!question.isAnonymous &&
                        (MySharedPreferences.userId != question.sender.id)) {
                      pushScreen(
                        context,
                        screen: ProfileScreen(userId: question.sender.id),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        if (question.isAnonymous)
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: AppColors.primary,
                            child: SvgPicture.asset(
                              AppIcons.anonymous,
                              height: 21,
                              width: 21,
                              color: AppColors.white,
                            ),
                          )
                        else
                          CustomNetworkImage(
                            url: question.sender.image.toString(),
                            radius: 999,
                            height: 30,
                            width: 30,
                          ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    question.isAnonymous
                                        ? !context.isCurrentLanguageAr()
                                              ? "Anonymous"
                                              : "مجهول"
                                        : question.sender.name,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // SizedBox(width: 1),
                                  // if (!question.isAnonymous && isVerified)
                                  //   SvgPicture.asset(
                                  //     AppIcons.verified,
                                  //     height: 15,
                                  //     width: 15,
                                  //     color: AppColors.primary,
                                  //   ),
                                ],
                              ),
                              Text(
                                question.isAnonymous
                                    ? "@x"
                                    : "@${question.sender.userName}",
                                maxLines: 1,
                                textDirection: TextDirection.ltr,

                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          timeAgo(
                            question.answeredAt ?? question.createdAt,
                            context,
                          ),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // --- Question title ---
                if (question.title.isNotEmpty)
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(
                        ClipboardData(text: question.title),
                      ).then((value) {
                        AppConstance().showInfoToast(
                          context,
                          msg: !context.isCurrentLanguageAr()
                              ? 'Question copied'
                              : 'تم نسخ السؤال',
                        );
                      });
                    },
                    child: Align(
                      alignment: isArabic(question.title)
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        question.title,
                        textDirection: isArabic(question.title)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        textAlign: isArabic(question.title)
                            ? TextAlign.right
                            : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 5),

                // --- Answer row ---
                if (question.answerText != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomNetworkImage(
                        url: MySharedPreferences.image,
                        radius: 999,
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: InkWell(
                           focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                          onTap: () {
                            // final text = question.answerText.toString();

                            // if (containsLink(text)) {
                            //   final url = extractLink(text);

                            //   if (url != null) {
                            //     LaunchUrlsService().launchBrowesr(
                            //       uri: url,
                            //       context: context,
                            //     );
                            //     return;
                            //   }
                            // }
                            // if (containsLink(question.answerText.toString())) {
                            //   LaunchUrlsService().launchBrowesr(
                            //     uri: question.answerText.toString(),
                            //     context: context,
                            //   );
                            // }
                          },

                          child: linkifyText(
                            context: context,
                            text: question.answerText.toString(),
                            isInProfileScreen: false,
                          ),
                          // child: Text(
                          //   "\"${question.answerText}\"",
                          //   textAlign: isArabic(question.answerText!)
                          //       ? TextAlign.right
                          //       : TextAlign.left,
                          //   textDirection: isArabic(question.answerText!)
                          //       ? TextDirection.rtl
                          //       : TextDirection.ltr,
                          //   style: TextStyle(
                          //     fontSize: containsLink(question.answerText.toString())
                          //         ? 14
                          //         : 16,
                          //     decoration: containsLink(question.answerText.toString())
                          //         ? TextDecoration.underline
                          //         : null,
                          //   ),
                          // ),
                        ),
                      ),
                    ],
                  ),

                if (question.images.isNotEmpty) const SizedBox(height: 5),
                if (question.images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: buildImages(question.images),
                  ),
                if (question.answerText != null) const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onImageTapped(int index, List<String> images) {
    pushScreen(
      context,
      screen: ImageViewScreen(
        images: images,
        initialIndex: index,
        title: '',
        onBack: (index) {},
      ),
    );
  }

  Widget buildImages(List<String> images) {
    if (images.isEmpty) return const SizedBox();

    // صورة واحدة
    if (images.length == 1) {
      return GestureDetector(
        onTap: () {
          // هنا تحط أي حدث عايز تنفذه عند الضغط
          print("Tapped image 0");
          onImageTapped(0, images);
        },
        child: CustomNetworkImage(
          radius: 18,
          boxFit: BoxFit.cover,
          url: images[0],
          height: 220,
          width: double.infinity,
        ),
      );
    }

    // صورتين
    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTapped(0, images),

              child: CustomNetworkImage(
                radius: 18,
                boxFit: BoxFit.cover,
                url: images[0],
                height: 180,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTapped(1, images),
              child: CustomNetworkImage(
                radius: 18,
                boxFit: BoxFit.cover,
                url: images[1],
                height: 180,
              ),
            ),
          ),
        ],
      );
    }

    // أكثر من صورتين
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onImageTapped(index, images),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomNetworkImage(
                  url: images[index],
                  height: 180,
                  width: 140,
                  radius: 18,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
