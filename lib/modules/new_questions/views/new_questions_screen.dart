// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/answer_question_card_details.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewQuestionsScreen extends StatefulWidget {
  const NewQuestionsScreen({super.key});

  @override
  State<NewQuestionsScreen> createState() => _NewQuestionsScreenState();
}

class _NewQuestionsScreenState extends State<NewQuestionsScreen> {
  bool isLoading = true;
  bool isMe = true;

  List<QuestionModel> questions = [];
  bool isQuestionsLoading = false; // تحميل الصفحة الأساسية
  bool isMoreLoading = false; // تحميل المزيد
  bool hasMore = true;
  DocumentSnapshot? lastDoc;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    getQuestions();
  }

  Future<void> getQuestions({bool isLoadMore = false}) async {
    if (isQuestionsLoading || isMoreLoading || !hasMore) return;

    if (isLoadMore) {
      setState(() => isMoreLoading = true);
    } else {
      setState(() => isQuestionsLoading = true);
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('questions')
          .where('receiver.id', isEqualTo: MySharedPreferences.userId)
          .where('isDeleted', isEqualTo: false)
          .where('answeredAt', isNull: true)
          .orderBy('answeredAt', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) query = query.startAfterDocument(lastDoc!);

      final querySnap = await query.get();

      if (querySnap.docs.isEmpty) {
        hasMore = false;
        return;
      }

      hasMore = querySnap.docs.length == limit;

      for (var doc in querySnap.docs) {
        final qData = doc.data() as Map<String, dynamic>;
        qData['id'] = doc.id;
        final q = QuestionModel.fromJson(qData);

        if (!questions.any((e) => e.id == q.id)) {
          questions.add(q);
        }
      }

      lastDoc = querySnap.docs.last;
    } catch (e) {
      debugPrint("Error loading questions: $e");
    } finally {
      if (isLoadMore) {
        setState(() => isMoreLoading = false);
      } else {
        setState(() => isQuestionsLoading = false);
      }
    }
  }

  Future<void> deleteQuestion(String id) async {
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(context, msg:!context.isCurrentLanguageAr() ? 'No internet connection' : 'لا يوجد اتصال بالانترنت');
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('questions').doc(id).update({
        'isDeleted': true,
      });
    } catch (e) {
      debugPrint("Error deleting question: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          !context.isCurrentLanguageAr() ? "New Questions" : "أسئلة جديدة",
        ),
      ),
      body: SafeArea(
        child: isQuestionsLoading
            ? Center(
                child: CupertinoActivityIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      color: AppColors.primary,

                      onRefresh: () async {
                        lastDoc = null;
                        hasMore = true;
                        questions.clear();
                        await getQuestions();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),

                        itemCount: questions.length + 1,

                        itemBuilder: (context, index) {
                          // ----------- لا يوجد أسئلة -----------
                          if (questions.isEmpty &&
                              index == 0 &&
                              !isQuestionsLoading) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LogoWidg(),

                                    Text(
                                      !context.isCurrentLanguageAr()
                                          ? 'No New questions for you yet'
                                          : "لا توجد أسئلة جديدة ليك",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // ----------- تحميل المزيد / الزرار -----------
                          if (index == questions.length) {
                            if (isMoreLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }

                            if (!hasMore) return const SizedBox(height: 40);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await getQuestions(isLoadMore: true);
                                  },
                                  child:  Text(!context.isCurrentLanguageAr()? "Load More" : "المزيد"),
                                ),
                              )
                            );
                          }

                          // ----------- باقي العناصر -----------
                          final q = questions[index];

                          return Dismissible(
                            key: ValueKey(q.id),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children:  [
                                      Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                      !context.isCurrentLanguageAr()?  'Delete' :    "حذف",
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
                                  title: !context.isCurrentLanguageAr()? 'Delete Question' :'حذف السؤال',
                                  onConfirm: () {},
                                  content:!context.isCurrentLanguageAr()? 'Are you sure you want to delete this question?' : 'هل  انت متاكد من حذف السؤال؟',
                                ),
                              );
                              if (res == true) {
                                await deleteQuestion(q.id);
                                setState(() {
                                  questions.removeAt(index);
                                });
                              }
                              return;
                            },

                            child: AnswerQuestionCardDetails(
                              afterBack: () {
                                questions.removeAt(index);
                                setState(() {});
                              },
                              isInAnswerQuestionScreen: false,
                              question: q,
                              currentProfileUserId: MySharedPreferences.userId,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
