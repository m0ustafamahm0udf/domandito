import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

class AskQuestionDetailsCard extends StatefulWidget {
  final QuestionModel question;
  final String displayName;
  final String receiverImage;
  final bool isVerified;
  final String currentProfileUserId;

  const AskQuestionDetailsCard({
    super.key,
    required this.question,
    required this.displayName,
    required this.receiverImage,
    required this.isVerified,
    required this.currentProfileUserId,
  });

  @override
  State<AskQuestionDetailsCard> createState() => _AskQuestionDetailsCardState();
}

class _AskQuestionDetailsCardState extends State<AskQuestionDetailsCard> {
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    question = widget.question; // نسخة داخلية
    likesCount = question.likesCount;
  }

  late QuestionModel question;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 20,

      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstance.hPadding,
          vertical: AppConstance.vPaddingTiny,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
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
                            !question.isAnonymous
                                ? question.sender.name
                                : !context.isCurrentLanguageAr()
                                ? 'Anonymous'
                                : 'مجهول',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                  timeAgo(question.answeredAt ?? question.createdAt, context),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // --- Question title ---
            if (question.title.isNotEmpty)
         Align(
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
            const SizedBox(height: 5),

            if (question.title.isNotEmpty) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
