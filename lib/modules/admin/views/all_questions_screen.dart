import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/shared/services/like_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/q_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllQuestionsScreen extends StatefulWidget {
  const AllQuestionsScreen({super.key});

  @override
  State<AllQuestionsScreen> createState() => _AllQuestionsScreenState();
}

class _AllQuestionsScreenState extends State<AllQuestionsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<QuestionModel> questions = [];
  int _offset = 0;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      _offset = 0;
      hasMore = true;
      questions.clear();
    }

    if (!hasMore) return;

    setState(() => isLoading = true);

    try {
      final List<dynamic> data = await _supabase
          .from('questions')
          .select(
            '*, sender:sender_id(id, name, username, image, is_verified), receiver:receiver_id(id, name, username, image, is_verified, token)',
          )
          .not('answered_at', 'is', null)
          .range(_offset, _offset + pageSize - 1)
          .order('created_at', ascending: false);

      if (data.isNotEmpty) {
        final newQuestions = data
            .map((json) => QuestionModel.fromJson(json))
            .toList();

        // 🚀 Batch Check Likes
        if (newQuestions.isNotEmpty) {
          final ids = newQuestions.map((e) => e.id).toList();
          final likedIds = await LikeService.getLikedQuestions(
            questionIds: ids,
            userId: MySharedPreferences.userId,
          );

          for (var q in newQuestions) {
            q.isLiked = likedIds.contains(q.id);
          }
        }

        questions.addAll(newQuestions);
        _offset += newQuestions.length;
      }

      hasMore = data.length == pageSize;
    } catch (e) {
      debugPrint('Error fetching questions: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary, // Match app background
      appBar: AppBar(
        title: const Text('All Questions'),
        leading: IconButton(
          onPressed: () => context.back(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          color: AppColors.primary,
          onRefresh: () => fetchQuestions(isRefresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: questions.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              if (index == questions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: hasMore
                        ? (isLoading
                              ? const CupertinoActivityIndicator(
                                  color: AppColors.primary,
                                )
                              : TextButton(
                                  onPressed: fetchQuestions,
                                  child: const Text("Load more"),
                                ))
                        : const SizedBox(),
                  ),
                );
              }

              final q = questions[index];
              return QuestionCard(
                question: q,
                receiverImage: q.receiver.image,
                receiverToken: q.receiver.token,
                isInProfileScreen:
                    false, // Or true? false is better for general list
                currentProfileUserId: MySharedPreferences.userId,
              );
            },
          ),
        ),
      ),
    );
  }
}
