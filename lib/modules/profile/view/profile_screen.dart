import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';

import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
// AccountScreen removed as it was unused
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/ask/views/ask_question_screen.dart';
import 'package:domandito/modules/following/views/following_screen.dart';
import 'package:domandito/shared/models/bloced_user.dart';
// blocked_user import might handle BlockUser class if not in block_service
import 'package:domandito/shared/models/follow_model.dart'; // FollowUser might be here
import 'package:domandito/shared/services/block_service.dart';
import 'package:domandito/shared/services/follow_service.dart';
import 'package:domandito/shared/services/report_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/download_dialog.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg_flutter.dart';
// Removed q_card as it should be used in ProfileQuestionsList

import 'package:domandito/modules/signin/models/user_model.dart';
// import 'package:domandito/modules/signin/signin_screen.dart'; // Add SignInScreen import
import 'package:domandito/modules/profile/view/widgets/profile_app_bar.dart';
import 'package:domandito/modules/profile/view/widgets/profile_image_section.dart';
import 'package:domandito/modules/profile/view/widgets/profile_info_section.dart';
import 'package:domandito/modules/profile/view/widgets/profile_stats_section.dart';
import 'package:domandito/modules/profile/view/widgets/profile_actions_section.dart';
import 'package:domandito/modules/profile/view/widgets/profile_questions_list.dart';
import 'package:domandito/modules/profile/view/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  // final String userUserName;
  final Function(bool)? onUnfollow;
  const ProfileScreen({
    super.key,
    required this.userId,
    this.onUnfollow,
    // this.userUserName = '',
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isLoading = true;
  bool isMe = false;

  List<QuestionModel> questions = [];
  bool isQuestionsLoading = false;
  bool hasMore = true;
  int _offset = 0;
  int limit = 10;
  bool isFollowing = false;

  bool isBlocked = false; // I blocked him
  bool amIBlockedByTarget = false; // He blocked me
  bool followLoading = false;
  bool blockLoading = false;

  int totalQuestionsCount = 0;

  @override
  void initState() {
    super.initState();
    isMe = widget.userId == MySharedPreferences.userId;
    getAllData();
    if (kIsWeb && !isMe) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDownloadAppDialog(context);
      });
    }
  }

  Future<void> getProfile() async {
    setState(() => isLoading = true);
    try {
      if (widget.userId.isNotEmpty) {
        final response = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', widget.userId)
            .maybeSingle(); // Use maybeSingle to handle no rows without error

        if (response != null) {
          user = UserModel.fromJson(response, response['id'].toString());
          if (isMe) {
            canAskedAnonymously = user!.canAskedAnonymously;
            MySharedPreferences.userName = user!.name;
            MySharedPreferences.userUserName = user!.userName;
            MySharedPreferences.phone = user!.phone;
            MySharedPreferences.bio = user!.bio;
            MySharedPreferences.email = user!.email;
            MySharedPreferences.image = user!.image;
            MySharedPreferences.isVerified = user!.isVerified;
          }
        } else {
          if (isMe) {
            MySharedPreferences.clearProfile(context: context);
          } else {
            context.back();
          }
        }
      }
      //  else {
      //   final doc = await FirebaseFirestore.instance
      //       .collection('users')
      //       .where('userName', isEqualTo: widget.userUserName)
      //       .limit(1)
      //       .get();
      //   if (doc.docs.isNotEmpty) {
      //     user = UserModel.fromFirestore(doc.docs.first);
      //     if (isMe) {
      //       canAskedAnonymously = user!.canAskedAnonymously;
      //       log('canAskedAnonymously $canAskedAnonymously');
      //       MySharedPreferences.userName = user!.name;
      //       MySharedPreferences.userUserName = user!.userName;
      //       MySharedPreferences.phone = user!.phone;
      //       MySharedPreferences.bio = user!.bio;
      //       MySharedPreferences.email = user!.email;
      //       MySharedPreferences.image = user!.image;
      //       MySharedPreferences.isVerified = user!.isVerified;
      //     }
      //     // await getQuestionsCount();
      //   } else {
      //     if (isMe) {
      //       MySharedPreferences.clearProfile(context: context);
      //     } else {
      //       context.back();
      //     }
      //   }
      // }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> getQuestionsCount() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .count()
          .eq('receiver_id', widget.userId)
          .eq('is_deleted', false)
          .not('answered_at', 'is', null);

      totalQuestionsCount = response;
      setState(() {});

      debugPrint("Total questions count: $totalQuestionsCount");
    } catch (e) {
      debugPrint("Error getting questions count: $e");
    }
  }

  Future<void> getQuestions() async {
    log(isBlocked.toString());
    if (isBlocked) return;
    // منع استدعاءات متزامنة أو لو مفيش بيانات إضافية
    if (isQuestionsLoading || !hasMore) return;

    setState(() => isQuestionsLoading = true);

    try {
      var query = Supabase.instance.client
          .from('questions')
          .select('*, sender:sender_id(*), receiver:receiver_id(*)')
          .eq('receiver_id', widget.userId)
          .eq('is_deleted', false)
          .not('answered_at', 'is', null);

      // Filter reported content
      if (MySharedPreferences.isLoggedIn) {
        final reportedIds = await ReportService.getReportedContentIds(
          MySharedPreferences.userId,
        );
        if (reportedIds.isNotEmpty) {
          query = query.not('id', 'in', '(${reportedIds.join(',')})');
        }
      }

      final List<dynamic> data = await query
          .order('answered_at', ascending: false)
          .order('created_at', ascending: false)
          .range(_offset, _offset + limit - 1);

      // لو مفيش داتا جديدة
      if (data.isEmpty) {
        hasMore = false;
        setState(() => isQuestionsLoading = false);
        return;
      }

      // لو عدد الدوكز أقل من اللِيمت يبقى مفيش المزيد بعد كده
      hasMore = data.length == limit;

      final newQuestions = data.map((json) {
        // Ensure json has valid structure for QuestionModel
        return QuestionModel.fromJson(json as Map<String, dynamic>);
      }).toList();

      for (var q in newQuestions) {
        final exists = questions.any((element) => element.id == q.id);
        if (!exists) questions.add(q);
      }

      // Update offset for next page
      _offset += newQuestions.length;
    } catch (e, st) {
      debugPrint("Error loading questions: $e\n$st");
    } finally {
      setState(() => isQuestionsLoading = false);
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
          .update({
            'answered_at': null,
            'answer_text': null,
            'images': [],
            // 'is_deleted': true, // The original code didn't set isDeleted=true, it cleared the answer. But the method name is deleteQuestion?
            // Re-reading original code:
            // .update({ 'answeredAt': null, 'answerText': null, 'images': [], });
            // This suggests created "unanswering" the question rather than deleting it?
            // The method is named deleteQuestion but the success message says "Unanswered successfully" / "تم التراجع عن الإجابة".
            // So it effectively "un-answers" it or "deletes the answer".
            // I will replicate this logic.
          })
          .eq('id', id);
      // await getQuestionsCount();

      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Unanswered successfully'
            : 'تم التراجع عن الإجابة',
      );
    } catch (e) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Error deleting question'
            : 'حدث خطأ',
      );
      debugPrint("Error deleting question: $e");
    }
  }

  Future<void> checkFollowing() async {
    if (!MySharedPreferences.isLoggedIn) {
      return;
    }
    if (!isMe) {
      isFollowing = await FollowService.isFollowing(
        myId: MySharedPreferences.userId,
        targetUserId: widget.userId,
      );
      setState(() {});
    }
  }

  Future<void> checkBlock() async {
    if (!MySharedPreferences.isLoggedIn) {
      return;
    }
    if (!isMe) {
      final results = await Future.wait([
        BlockService.isBlocked(
          myId: MySharedPreferences.userId,
          targetUserId: widget.userId,
        ),
        BlockService.amIBlocked(
          myId: MySharedPreferences.userId,
          targetUserId: widget.userId,
        ),
      ]);

      isBlocked = results[0];
      amIBlockedByTarget = results[1];

      setState(() {});
    }
    log('isBlocked $isBlocked');
  }

  getAllData() async {
    await checkBlock();
    await Future.wait([
      getProfile(),
      getQuestions(),
      checkFollowing(),
      getQuestionsCount(),
    ]);
  }

  Future<void> toggleFollowAction() async {
    if (!MySharedPreferences.isLoggedIn) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please log in'
            : 'يرجى تسجيل الدخول',
        isLogin: true,
      );

      return;
    }
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }

    /// نص الدايلوج بناءً على الحالة
    final title = isFollowing
        ? !context.isCurrentLanguageAr()
              ? 'Unfollow'
              : "إلغاء المتابعة"
        : !context.isCurrentLanguageAr()
        ? 'Follow'
        : "متابعة ${user!.name}";

    final content = isFollowing
        ? !context.isCurrentLanguageAr()
              ? "Are you sure you want to unfollow ${user!.name}?"
              : "هل أنت متأكد أنك تريد إلغاء متابعة ${user!.name}؟"
        : !context.isCurrentLanguageAr()
        ? "Are you sure you want to follow ${user!.name}?"
        : "هل تريد متابعة ${user!.name}؟";

    /// عرض الدايلوج
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          CustomDialog(title: title, content: content, onConfirm: () {}),
    );
    if (confirmed == false) {
      return;
    }
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }
    if (followLoading || user == null) return;

    setState(() => followLoading = true);

    final me = FollowUser(
      id: MySharedPreferences.userId,
      name: MySharedPreferences.userName,
      image: MySharedPreferences.image,
      userName: MySharedPreferences.userUserName,
      userToken: MySharedPreferences.deviceToken,
    );

    final target = FollowUser(
      userName: user!.userName,
      id: user!.id,
      name: user!.name,
      image: user!.image,
      userToken: user!.token,
    );

    final newState = await FollowService.toggleFollow(
      me: me,
      targetUser: target,
      context: context,
    );

    // تحديث الحالة مباشرة
    if (newState) {
      user!.followersCount++;
      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Followed successfully'
            : 'تم المتابعة',
      );
      log(user!.token + ' token');
      await SendMessageNotificationWithHTTPv1().send2(
        type: AppConstance.follow,
        urll: '',
        toToken: user!.token,
        message: AppConstance.followed,
        title: 'Domandito',
        id: '',
      );
    } else {
      //////
      //
      if (widget.onUnfollow != null) {
        widget.onUnfollow!(true);
      }
      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Unfollowed successfully'
            : 'تم الغاء المتابعة',
      );
      user!.followersCount--;
    }

    setState(() {
      isFollowing = newState;
      followLoading = false;
    });
  }

  Future<void> toggleBlockAction() async {
    if (!MySharedPreferences.isLoggedIn) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please log in'
            : 'يرجى تسجيل الدخول',
        isLogin: true,
      );
      return;
    }

    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }

    // نص الدايلوج بناءً على حالة البلوك الحالية
    final title = isBlocked
        ? (!context.isCurrentLanguageAr() ? 'Unblock' : "رفع الحظر")
        : (!context.isCurrentLanguageAr() ? 'Block' : "حظر ${user!.name}");

    final content = isBlocked
        ? (!context.isCurrentLanguageAr()
              ? "Are you sure you want to unblock ${user!.name}?"
              : "هل أنت متأكد أنك تريد رفع الحظر عن ${user!.name}؟")
        : (!context.isCurrentLanguageAr()
              ? "Are you sure you want to block ${user!.name}?"
              : "هل أنت متأكد أنك تريد حظر ${user!.name}؟");

    // عرض الدايلوج
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          CustomDialog(title: title, content: content, onConfirm: () {}),
    );

    if (confirmed == false) return;

    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }

    if (blockLoading || user == null) return;

    setState(() => blockLoading = true);

    final me = BlockUser(
      id: MySharedPreferences.userId,
      name: MySharedPreferences.userName,
      userName: MySharedPreferences.userUserName,
      image: MySharedPreferences.image,
    );

    final target = BlockUser(
      id: user!.id,
      name: user!.name,
      userName: user!.userName,
      image: user!.image,
    );

    // Verify Auth State
    // final authId = Supabase.instance.client.auth.currentUser?.id;
    // Check for ID mismatch (Legacy SharedPrefs vs Supabase Auth)
    // if (me.id != authId) {
    //   // Clear data & Logout
    //   await MySharedPreferences.clearProfile(context: context);

    //   if (context.mounted) {
    //     AppConstance().showInfoToast(
    //       context,
    //       msg: !context.isCurrentLanguageAr()
    //           ? "Session expired. Please login again."
    //           : "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.",
    //     );
    //     pushReplacementWithoutNavBar(
    //       context,
    //       MaterialPageRoute(builder: (context) => SignInScreen()),
    //     );
    //   }
    //   setState(() => blockLoading = false);
    //   return;
    // }

    final newState = await BlockService.toggleBlock(
      blocker: me,
      blocked: target,
      context: context,
    );

    // تحديث الحالة مباشرة
    if (newState) {
      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'User blocked successfully'
            : 'تم حظر المستخدم',
      );
      if (isFollowing) {
        FollowUser me = FollowUser(
          userToken: MySharedPreferences.deviceToken,
          id: MySharedPreferences.userId,
          name: MySharedPreferences.userName,
          userName: MySharedPreferences.userUserName,
          image: MySharedPreferences.image,
        );

        FollowUser target = FollowUser(
          userToken: user!.token,
          id: user!.id,
          name: user!.name,
          userName: user!.userName,
          image: user!.image,
        );
        await FollowService.toggleFollow(
          me: me,
          targetUser: target,
          context: context,
        );
      }

      context.back();
      // TODO: اختياري: مسح أو فلترة المحتوى فورًا من الـ feed
      // مثلا: remove blocked user's posts from the UI list
    } else {
      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'User unblocked successfully'
            : 'تم رفع الحظر عن المستخدم',
      );
      await getAllData();
    }

    setState(() {
      isBlocked = newState;
      blockLoading = false;
    });
  }

  bool canAskedAnonymously = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(user: user, isLoading: isLoading, isMe: isMe),
      body: (isBlocked || amIBlockedByTarget)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoWidg(),
                  // Icon(Icons.block, size: 64, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    !context.isCurrentLanguageAr()
                        ? 'User is unavailable'
                        : 'المستخدم غير متاح',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isBlocked) ...[
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: toggleBlockAction,
                      child: Text(
                        !context.isCurrentLanguageAr()
                            ? 'Unblock'
                            : 'إلغاء الحظر',
                      ),
                    ),
                  ],
                ],
              ),
            )
          : isLoading
          ? Center(child: CupertinoActivityIndicator(color: AppColors.primary))
          : user == null
          ? const Center(child: Text(''))
          : RefreshIndicator.adaptive(
              color: AppColors.primary,

              onRefresh: () async {
                _offset = 0;
                hasMore = true;
                questions.clear();
                await getAllData();
                await getQuestionsCount();
                setState(() {});
              },
              child: ListView(
                padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                children: [
                  ProfileImageSection(
                    user: user!,
                    isMe: isMe,
                    isBlocked: isBlocked,
                    onEditProfile: () {
                      pushScreen(
                        context,
                        screen: const EditProfileScreen(),
                      ).then((value) {
                        if (value == true) {
                          // Refresh profile after coming back from edit
                          getProfile();
                          setState(() {});
                        }
                      });
                    },
                  ),

                  // const SizedBox(height: 0),
                  ProfileInfoSection(
                    user: user!,
                    isMe: isMe,
                    isBlocked: isBlocked,
                    blockLoading: blockLoading,
                    onToggleBlock: toggleBlockAction,
                  ),

                  const SizedBox(height: 15),

                  ProfileStatsSection(
                    user: user!,
                    isMe: isMe,
                    onFollowingTap: () {
                      if (isMe) {
                        pushScreen(
                          context,
                          screen: FollowingScreen(
                            followingCount: (count) {
                              user!.followingCount = count;
                              setState(() {});
                            },
                          ),
                        ).then((value) async {
                          //  await getProfile();
                        });
                      }
                    },
                    questionsCount: totalQuestionsCount,
                  ),

                  const SizedBox(height: 15),
                  ProfileActionsSection(
                    user: user!,
                    isMe: isMe,
                    isFollowing: isFollowing,
                    followLoading: followLoading,
                    isBlocked: isBlocked,
                    onAsk: () {
                      if (!MySharedPreferences.isLoggedIn) {
                        AppConstance().showInfoToast(
                          context,
                          msg: !context.isCurrentLanguageAr()
                              ? 'Please log in'
                              : 'يرجى تسجيل الدخول',
                          isLogin: true,
                        );

                        return;
                      }

                      pushScreen(
                        context,
                        screen: AskQuestionScreen(
                          canAskedAnonymously: user!.canAskedAnonymously,
                          recipientToken: user!.token,
                          recipientUserName: user!.userName,
                          isVerified: user!.isVerified,
                          recipientId: user!.id,
                          recipientName: user!.name,
                          recipientImage: user!.image,
                        ),
                      );
                    },
                    onToggleFollow: toggleFollowAction,
                  ),

                  const SizedBox(height: 4),
                  // Anonymous Switch moved to EditProfileScreen

                  // UserShareCard(username: user!.name, userImage: user!.image),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(thickness: 0.1, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),

                  if (isBlocked)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LogoWidg(),

                          Text(
                            !context.isCurrentLanguageAr()
                                ? 'You blocked this user'
                                : "تم حظر هذا المستخدم",
                          ),
                        ],
                      ),
                    ),
                  if (questions.isEmpty && !isQuestionsLoading && !isBlocked)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LogoWidg(),
                          if (isMe)
                            Text(
                              !context.isCurrentLanguageAr()
                                  ? 'You have not received any questions yet'
                                  : "لم تستقبل أي أسئلة بعد",
                            )
                          else
                            Text(
                              !context.isCurrentLanguageAr()
                                  ? 'have not received any questions yet'
                                  : "لم يستقبل أي أسئلة بعد",
                            ),
                        ],
                      ),
                    )
                  else
                    ProfileQuestionsList(
                      questions: questions,
                      user: user!,
                      isMe: isMe,
                      onDeleteQuestion: (id) async {
                        await deleteQuestion(id);
                        // Note: parent doesn't strictly know which index here unless we find it
                        // The original logic removed by index in Dismissible confirmDismiss
                        // But if we call this callback, we might want to refresh or rely on setState passed down?
                        // The ProfileQuestionsList widget handles the specific item removal via dismissible logic?
                        // Ah, wait. In ProfileQuestionsList I wrote:
                        // if (res == true) { onDeleteQuestion(q.id); } return false;
                        // So the UI won't animate removal automatically if I return false.
                        // But if I want to remove it from `questions` list in parent:
                        setState(() {
                          questions.removeWhere((element) => element.id == id);
                        });
                      },
                    ),

                  if (kIsWeb)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          !context.isCurrentLanguageAr()
                              ? 'Download the app'
                              : 'تحميل التطبيق',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        // const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                LaunchUrlsService().launchBrowesr(
                                  uri: AppConstance.appStoreUrl,
                                  context: context,
                                );
                              },
                              label: const Text('App Store'),
                              icon: SvgPicture.asset(
                                AppIcons.appstore,
                                height: 25,
                                width: 25,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                LaunchUrlsService().launchBrowesr(
                                  uri: AppConstance.googleplayUrl,
                                  context: context,
                                );
                              },
                              label: const Text('Google Play'),

                              icon: SvgPicture.asset(
                                AppIcons.googleplay,
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  // const SizedBox(height: 2),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Builder(
                        builder: (context) {
                          if (!hasMore && questions.isNotEmpty) {
                            return SizedBox();
                          }
                          if (isQuestionsLoading) {
                            return const SizedBox(
                              height: 36,
                              width: 36,
                              child: CupertinoActivityIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }
                          if (questions.isEmpty) {
                            return const SizedBox();
                          }
                          return ElevatedButton(
                            onPressed: (hasMore && !isQuestionsLoading)
                                ? () async {
                                    await getQuestions();
                                  }
                                : null,
                            child: Text(
                              !context.isCurrentLanguageAr()
                                  ? "Load more"
                                  : "المزيد",
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
