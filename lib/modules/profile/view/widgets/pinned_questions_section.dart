import 'package:domandito/core/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/shared/widgets/q_card.dart';
import 'package:domandito/shared/style/app_colors.dart';

class PinnedQuestionsSection extends StatelessWidget {
  final List<QuestionModel> pinnedQuestions;
  final String currentProfileUserId;
  final String receiverImage;
  final String receiverToken;
  final bool isMe;
  final Function(bool isPinned, String questionId)? onPinToggle;

  const PinnedQuestionsSection({
    super.key,
    required this.pinnedQuestions,
    required this.currentProfileUserId,
    required this.receiverImage,
    required this.receiverToken,
    required this.isMe,
    this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (pinnedQuestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0, right: 16, left: 16),
          child: Row(
            children: [
              Icon(Icons.push_pin, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pinned Questions', // You might want to localize this
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170, // Height for the horizontal list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: 16,
              bottom: 10,
              top: 10,
              right: 16,
            ),
            itemCount: pinnedQuestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 5),
            itemBuilder: (context, index) {
              return SizedBox(
                width: context.w * .87, // Fixed width for each card
                child: QuestionCard(
                  question: pinnedQuestions[index],
                  receiverImage: receiverImage,
                  receiverToken: receiverToken,
                  currentProfileUserId: currentProfileUserId,
                  isInProfileScreen: true,
                  onPinToggle: (isPinned) {
                    onPinToggle?.call(isPinned, pinnedQuestions[index].id);
                  },
                ),
              );
            },
          ),
        ),
        // const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.only(top: 0, right: 20, left: 20),

          child: const Divider(thickness: 0.1, color: AppColors.primary),
        ),
      ],
    );
  }
}
