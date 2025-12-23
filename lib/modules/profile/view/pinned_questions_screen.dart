import 'package:domandito/modules/profile/view/widgets/pinned_questions_section.dart';
import 'package:flutter/material.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';

class PinnedQuestionsScreen extends StatelessWidget {
  final List<QuestionModel> pinnedQuestions;
  final String currentProfileUserId;
  final String receiverImage;
  final String receiverToken;
  final bool isMe;

  const PinnedQuestionsScreen({
    super.key,
    required this.pinnedQuestions,
    required this.currentProfileUserId,
    required this.receiverImage,
    required this.receiverToken,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinned Questions'), centerTitle: true),
      body: pinnedQuestions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoWidg(),
                  const SizedBox(height: 16),
                  const Text('No pinned questions yet'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: PinnedQuestionsSection(
                pinnedQuestions: pinnedQuestions,
                currentProfileUserId: currentProfileUserId,
                receiverImage: receiverImage,
                receiverToken: receiverToken,
                isMe: isMe,
              ),
            ),
    );
  }
}
