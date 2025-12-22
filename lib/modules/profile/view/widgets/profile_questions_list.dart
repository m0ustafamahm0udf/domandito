import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/q_card.dart';
import 'package:flutter/material.dart';

class ProfileQuestionsList extends StatelessWidget {
  final List<QuestionModel> questions;
  final UserModel user;
  final bool isMe;
  final Function(String) onDeleteQuestion;

  const ProfileQuestionsList({
    super.key,
    required this.questions,
    required this.user,
    required this.isMe,
    required this.onDeleteQuestion,
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
        if (isMe) {
          return Dismissible(
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
              return false; // We handle removal in parent manually via setState usually, or allow dismiss if parent updates list
              // In parent logic: await deleteQuestion(q.id); setState(() { questions.removeAt(index); });
              // So returning true here might remove it from UI before parent updates?
              // The original code returned 'res' which is true/false.
              // We should return true if we want Dismissible to remove it, but parent state sync is important.
            },
            child: QuestionCard(
              receiverToken: user.token,
              currentProfileUserId: user.id,
              question: q,
              receiverImage: user.image,
            ),
          );
        }
        return QuestionCard(
          receiverToken: user.token,
          currentProfileUserId: user.id,
          question: q,
          receiverImage: user.image,
        );
      },
    );
  }
}
