import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/shared/models/like_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg.dart';

class LikesList extends StatefulWidget {
  final String questionId;
  final QuestionModel question;

  const LikesList({
    super.key,
    required this.questionId,
    required this.question,
  });

  @override
  State<LikesList> createState() => _LikesListState();
}

class _LikesListState extends State<LikesList> {
  final _supabase = Supabase.instance.client;

  List<LikeModel> likes = [];
  String? lastCreatedAt; // For keyset pagination
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchLikes();
  }

  Future<void> fetchLikes() async {
    if (widget.question.receiver.id != MySharedPreferences.userId) return;
    if (!hasMore || isLoading) return;

    setState(() => isLoading = true);

    try {
      var query = _supabase
          .from('likes')
          .select('*, users(*)') // Fetch fresh user data via FK Join
          .eq('question_id', widget.questionId);

      if (lastCreatedAt != null) {
        query = query.lt('created_at', lastCreatedAt!);
      }

      final List<dynamic> data = await query
          .order('created_at', ascending: false)
          .limit(pageSize);

      if (data.isNotEmpty) {
        final newLikes = data.map((json) => LikeModel.fromJson(json)).toList();
        likes.addAll(newLikes);

        // Update cursor
        lastCreatedAt = data.last['created_at'];
      }

      if (data.length < pageSize) {
        hasMore = false;
      }
    } catch (e) {
      debugPrint('Error fetching likes: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (likes.isEmpty &&
        // !isLoading &&
        widget.question.receiver.id == MySharedPreferences.userId) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstance.hPaddingTiny),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // if (!isLoading)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SvgPicture.asset(
                AppIcons.heart,
                color: AppColors.primary,
                height: 22,
              ),
              const SizedBox(width: 4),
              Text(
                formatNumber(widget.question.likesCount),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.question.receiver.id == MySharedPreferences.userId)
            ListView.separated(
              padding: EdgeInsets.only(top: 5),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: likes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final like = likes[index];
                return GestureDetector(
                  onTap: () {
                    if (like.user.id == widget.question.receiver.id) {
                      context.back();
                      return;
                    }
                    if ((MySharedPreferences.userId != like.user.id)) {
                      pushScreen(
                        context,
                        screen: ProfileScreen(userId: like.user.id),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        CustomNetworkImage(
                          url: MySharedPreferences.userId == like.user.id
                              ? MySharedPreferences.image
                              : like.user.image,
                          radius: 999,
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                like.user.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "@${like.user.userName}",
                                textDirection: TextDirection.ltr,

                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (MySharedPreferences.userId == like.user.id)
                          Text(
                            !context.isCurrentLanguageAr() ? 'You' : 'أنت',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (hasMore &&
              widget.question.receiver.id == MySharedPreferences.userId)
            Center(
              child: TextButton(
                onPressed: fetchLikes,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CupertinoActivityIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        !context.isCurrentLanguageAr() ? "Load more" : "المزيد",
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
