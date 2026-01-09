import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/q_card.dart';
import 'package:flutter/material.dart';
import 'package:domandito/shared/style/app_colors.dart';

class ProfileQuestionsList extends StatelessWidget {
  final List<QuestionModel> questions;
  final UserModel user;
  final bool isMe;
  final Function(String) onDeleteQuestion;
  final Function(bool isPinned, String questionId)? onPinToggle;
  final bool Function()? canPin;

  const ProfileQuestionsList({
    super.key,
    required this.questions,
    required this.user,
    required this.isMe,
    required this.onDeleteQuestion,
    this.onPinToggle,
    this.canPin,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        Widget card;

        if (isMe) {
          card = Dismissible(
            key: ValueKey(q.id),
            direction: DismissDirection.startToEnd,
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white, size: 30),
                      SizedBox(height: 4),
                      Text(
                        !context.isCurrentLanguageAr() ? "Delete" : "حذف",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              final res = await showDialog(
                context: context,
                builder: (context) => CustomDialog(
                  title: !context.isCurrentLanguageAr()
                      ? 'Delete question'
                      : 'حذف السؤال',
                  onConfirm: () {},
                  content: !context.isCurrentLanguageAr()
                      ? 'Are you sure you want to delete the question?'
                      : 'هل  انت متاكد من حذف السؤال؟',
                ),
              );
              if (res == true) {
                onDeleteQuestion(q.id);
              }
              return false;
            },
            child: QuestionCard(
              receiverToken: user.token,
              currentProfileUserId: user.id,
              question: q,
              receiverImage: user.image,
              onPinToggle: (isPinned) => onPinToggle?.call(isPinned, q.id),
              canPin: canPin,
            ),
          );
        } else {
          card = QuestionCard(
            receiverToken: user.token,
            currentProfileUserId: user.id,
            question: q,
            receiverImage: user.image,
            onPinToggle: (isPinned) => onPinToggle?.call(isPinned, q.id),
            canPin: canPin,
          );
        }

        if (q.isPinned) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              card,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Divider(thickness: 0.1, color: AppColors.primary),
              ),
            ],
          );
        }

        return card;
      },
    );
  }
}
