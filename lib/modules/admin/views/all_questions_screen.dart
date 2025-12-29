import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
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
      // Fetch Questions using RPC (Server-side optimization)
      final List<dynamic> data = await _supabase.rpc(
        'get_all_questions',
        params: {
          'p_user_id': MySharedPreferences.userId,
          'p_limit': pageSize,
          'p_offset': _offset,
        },
      );

      if (data.isNotEmpty) {
        final newQuestions = data
            .map((json) => QuestionModel.fromJson(json))
            .toList();

        // Note: isLiked is already calculated by the RPC!

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
