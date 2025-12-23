// }

import 'package:supabase_flutter/supabase_flutter.dart';
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
  int _offset = 0;
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
      final query = Supabase.instance.client
          .from('questions')
          .select('*, sender:sender_id(id, name, username, image, is_verified)')
          .eq('receiver_id', MySharedPreferences.userId)
          .eq('is_deleted', false)
          .filter('answered_at', 'is', null) // Use filter for IS NULL
          // .order('answered_at', ascending: false) // answered_at is null here, so ordering by it is pointless
          .order('created_at', ascending: false)
          .range(_offset, _offset + limit - 1);

      final List<dynamic> data = await query;

      if (data.isEmpty) {
        hasMore = false;
        if (isLoadMore)
          setState(() => isMoreLoading = false);
        else
          setState(() => isQuestionsLoading = false);
        return;
      }

      hasMore = data.length == limit;

      final myReceiverData = {
        'id': MySharedPreferences.userId,
        'name': MySharedPreferences.userName,
        'username': MySharedPreferences.userUserName,
        'image': MySharedPreferences.image,
        'is_verified': MySharedPreferences.isVerified,
        'token': MySharedPreferences.deviceToken,
      };

      final newQuestions = data.map((json) {
        json['receiver'] = myReceiverData;
        return QuestionModel.fromJson(json);
      }).toList();

      for (var q in newQuestions) {
        if (!questions.any((e) => e.id == q.id)) {
          questions.add(q);
        }
      }

      _offset += newQuestions.length;
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
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }
    try {
      await Supabase.instance.client
          .from('questions')
          .update({'is_deleted': true})
          .eq('id', id);
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
                        _offset = 0;
                        hasMore = true;
                        questions.clear();
                        await getQuestions();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
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
                                  child: Text(
                                    !context.isCurrentLanguageAr()
                                        ? "Load More"
                                        : "المزيد",
                                  ),
                                ),
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        !context.isCurrentLanguageAr()
                                            ? 'Delete'
                                            : "حذف",
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
                                      ? 'Delete Question'
                                      : 'حذف السؤال',
                                  onConfirm: () {},
                                  content: !context.isCurrentLanguageAr()
                                      ? 'Are you sure you want to delete this question?'
                                      : 'هل  انت متاكد من حذف السؤال؟',
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
