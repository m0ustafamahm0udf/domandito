import 'package:domandito/core/services/global_privacy_service.dart';
import 'package:domandito/modules/profile/services/profile_visit_service.dart';
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
import 'package:domandito/modules/notifications/repositories/notifications_repository.dart';
import 'package:domandito/shared/models/bloced_user.dart';
// blocked_user import might handle BlockUser class if not in block_service
import 'package:domandito/shared/models/follow_model.dart'; // FollowUser might be here
import 'package:domandito/shared/services/block_service.dart';
import 'package:domandito/shared/services/follow_service.dart';
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
import 'package:domandito/shared/helpers/scroll_to_top_helper.dart';
import 'package:domandito/shared/services/question_service.dart';

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

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  UserModel? user;
  bool isLoading = true;
  bool isError = false;
  bool isMe = false;

  List<QuestionModel> questions = [];
  List<QuestionModel> pinnedQuestions = [];
  List<QuestionModel> unpinnedQuestions = [];
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

  late ScrollToTopHelper _scrollHelper;

  @override
  void initState() {
    super.initState();
    _scrollHelper = ScrollToTopHelper(onScrollComplete: () {});
    isMe = widget.userId == MySharedPreferences.userId;
    getAllData();
    _checkAccess();
  }

  void _checkAccess() {
    if (isMe) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Don't show checks for myself

      // 1. Web Check
      if (kIsWeb) {
        showDownloadAppDialog(context);
        return;
      }

      // 2. Login Check
      if (!MySharedPreferences.isLoggedIn) {
        showMustLoginDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollHelper.dispose();
    // PrivacyService().disableSecureMode();
    super.dispose();
  }

  Future<void> getAllData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final myId = MySharedPreferences.userId;
      final targetId = widget.userId;

      final response = await Supabase.instance.client.rpc(
        'get_full_profile',
        params: {
          'p_my_id': (myId.isEmpty || myId == '0') ? null : myId,
          'p_target_id': targetId,
        },
      );

      if (response != null) {
        // 1. User Data
        user = UserModel.fromJson(
          response['user'],
          response['user']['id'].toString(),
        );

        // Update SharedPreferences if it's me
        if (isMe) {
          canAskedAnonymously = user!.canAskedAnonymously;
          MySharedPreferences.userName = user!.name;
          MySharedPreferences.userUserName = user!.userName;
          MySharedPreferences.phone = user!.phone;
          MySharedPreferences.bio = user!.bio;
          MySharedPreferences.email = user!.email;
          MySharedPreferences.image = user!.image;
          MySharedPreferences.isVerified = user!.isVerified;
          GlobalPrivacyService().evaluatePrivacyParameters();
        } else {
          ProfileVisitService.recordVisit(
            targetUserId: user!.id,
            targetUserToken: user!.token,
            context: context,
          );

          // Enable Privacy / Screenshot Protection
          // Privacy handled globally now
          // PrivacyServiceV6().enableSecureMode(
          //   context: context,
          //   targetUserId: user!.id,
          //   targetUserToken: user!.token,
          // );
        }

        // 2. Stats
        totalQuestionsCount = response['stats']['questions_count'] ?? 0;

        // 3. Relationship
        final rel = response['relationship'];
        isFollowing = rel['is_following'] ?? false;
        isBlocked = rel['is_blocked_by_me'] ?? false;
        amIBlockedByTarget = rel['is_blocked_by_target'] ?? false;

        // Fetch questions after profile data is ready
        await getQuestions();
      } else {
        if (isMe) {
          MySharedPreferences.clearProfile(context: context);
        } else {
          // Instead of popping, show error state
          setState(() => isError = true);
        }
      }
    } catch (e) {
      debugPrint("Error fetching full profile: $e");
      setState(() => isError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> getQuestions() async {
    // منع استدعاءات متزامنة أو لو مفيش بيانات إضافية
    if (isQuestionsLoading || !hasMore) return;

    setState(() => isQuestionsLoading = true);

    try {
      final myId = MySharedPreferences.userId;

      final response = await Supabase.instance.client.rpc(
        'get_profile_questions',
        params: {
          'p_my_id': (myId.isEmpty || myId == '0') ? null : myId,
          'p_target_id': widget.userId,
          'p_limit': limit,
          'p_offset': _offset,
        },
      );

      final List<dynamic> data = response as List<dynamic>;

      // لو مفيش داتا جديدة
      if (data.isEmpty) {
        hasMore = false;
        setState(() => isQuestionsLoading = false);
        return;
      }

      // لو عدد الدوكز أقل من اللِيمت يبقى مفيش المزيد بعد كده
      hasMore = data.length == limit;

      final newQuestions = data.map((json) {
        // The RPC returns 'receiver' object, but we want to make sure the model uses it correctly
        // The RPC output structure for receiver and sender matches what QuestionModel expects.
        // is_liked is also returned directly (boolean).

        // Fix: is_liked coming from RPC might be named 'is_liked', but Model might expect just 'is_liked' or handle it?
        // Let's check QuestionModel.fromJson later if issues arise, but usually it parses map.
        // We know our RPC returns 'is_liked'. QuestionModel often has a field for it.

        return QuestionModel.fromJson(json as Map<String, dynamic>);
      }).toList();

      for (var q in newQuestions) {
        final exists = questions.any((element) => element.id == q.id);
        if (!exists) questions.add(q);
      }

      // Sort: Pinned first, then Newest
      questions.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        final aTime = a.answeredAt ?? a.createdAt;
        final bTime = b.answeredAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      // pinnedQuestions = questions.where((q) => q.isPinned).toList();
      // unpinnedQuestions = questions.where((q) => !q.isPinned).toList();

      // No need for separate LikeService call (RPC handles is_liked)

      // Update offset for next page
      _offset += newQuestions.length;
    } catch (e, st) {
      debugPrint("Error loading profile questions: $e\n$st");
    } finally {
      setState(() => isQuestionsLoading = false);
    }
  }

  Future<bool> deleteQuestion(String id) async {
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return false;
    }
    try {
      await Supabase.instance.client
          .from('questions')
          .update({
            'answered_at': null,
            'answer_text': null,
            'images': [],
            'video_url': null,
            'thumbnail_url': null,
            'media_type': null,
            'is_edited': false, // Reset edited status
          })
          .eq('id', id);
      // await getQuestionsCount();

      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Unanswered successfully'
            : 'تم التراجع عن الإجابة',
      );
      return true;
    } catch (e) {
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Error deleting question'
            : 'حدث خطأ',
      );
      debugPrint("Error deleting question: $e");
      return false;
    }
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
      await Future.wait([
        SendMessageNotificationWithHTTPv1().send2(
          type: AppConstance.follow,
          urll: '',
          toToken: user!.token,
          message: AppConstance.followed,
          title: 'Domandito',
          id: '',
        ),
        NotificationsRepository().sendNotification(
          senderId: MySharedPreferences.userId,
          receiverId: user!.id,
          type: AppConstance.follow,
          title: 'Domandito',
          body: AppConstance.followed,
        ),
      ]);
      // Send persistent notification to Supabase
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
        // Follow relationship is already handled by BlockService.toggleBlock
        // which calls forceUnfollow internally. No need to toggle again.
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
    super.build(context);
    return Scaffold(
      appBar: ProfileAppBar(user: user, isLoading: isLoading, isMe: isMe),
      floatingActionButton: _scrollHelper.buildButton(),
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
          : (user == null || isError)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoWidg(),
                  const SizedBox(height: 16),
                  Text(
                    !context.isCurrentLanguageAr()
                        ? 'Something went wrong'
                        : 'حدث خطأ ما',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: getAllData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      !context.isCurrentLanguageAr()
                          ? 'Retry'
                          : 'إعادة المحاولة',
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator.adaptive(
              color: AppColors.primary,

              onRefresh: () async {
                _offset = 0;
                hasMore = true;
                questions.clear();
                pinnedQuestions.clear();
                unpinnedQuestions.clear();
                await getAllData();
                setState(() {});
              },
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                controller: _scrollHelper.scrollController,
                padding: EdgeInsets.only(top: 0, right: 0, left: 0),
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0, right: 16, left: 16),

                    child: ProfileImageSection(
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
                            getAllData();
                            setState(() {});
                          }
                        });
                      },
                    ),
                  ),

                  // const SizedBox(height: 0),
                  Padding(
                    padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                    child: ProfileInfoSection(
                      user: user!,
                      isMe: isMe,
                      isBlocked: isBlocked,
                      blockLoading: blockLoading,
                      onToggleBlock: toggleBlockAction,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Padding(
                    padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                    child: ProfileStatsSection(
                      user: user!,
                      isMe: isMe,
                      onFollowingTap: () {
                        if (isMe) {
                          pushScreen(
                            context,
                            screen: FollowingScreen(
                              // followingCount: (count) {
                              //   user!.followingCount = count;
                              //   setState(() {});
                              // },
                            ),
                          ).then((value) async {
                            //  await getProfile();
                          });
                        }
                      },
                      questionsCount: totalQuestionsCount,
                    ),
                  ),

                  const SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                    child: ProfileActionsSection(
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
                  ),

                  const SizedBox(height: 4),
                  // Anonymous Switch moved to EditProfileScreen

                  // UserShareCard(username: user!.name, userImage: user!.image),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.push_pin,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.isCurrentLanguageAr()
                              ? 'الأسئلة المثبتة'
                              : 'Pinned Question',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PinnedQuestionsSection(
                  //   pinnedQuestions: pinnedQuestions,
                  //   currentProfileUserId: widget.userId,
                  //   receiverImage: user?.image ?? '',
                  //   receiverToken: user?.token ?? '',
                  //   isMe: isMe,
                  //   onPinToggle: (isPinned, id) {
                  //     setState(() {
                  //       if (!isPinned) {
                  //         // Move from pinned to unpinned
                  //         final index = pinnedQuestions.indexWhere(
                  //           (e) => e.id == id,
                  //         );
                  //         if (index != -1) {
                  //           final q = pinnedQuestions.removeAt(index);
                  //           q.isPinned = false;
                  //           unpinnedQuestions.insert(0, q);
                  //           // Sort unpinned by date (answeredAt or createdAt descending)
                  //           unpinnedQuestions.sort((a, b) {
                  //             final aTime = a.answeredAt ?? a.createdAt;
                  //             final bTime = b.answeredAt ?? b.createdAt;
                  //             return bTime.compareTo(aTime);
                  //           });
                  //         }
                  //       }
                  //     });
                  //   },
                  // ),
                  if (questions.isEmpty)
                    const SizedBox()
                  else
                    Padding(
                      padding: EdgeInsets.only(top: 4, right: 16, left: 16),
                      child: ProfileQuestionsList(
                        questions: questions,
                        user: user!,
                        isMe: isMe,
                        onDeleteQuestion: (id) async {
                          final success = await deleteQuestion(id);
                          if (success && context.mounted) {
                            setState(() {
                              questions.removeWhere(
                                (element) => element.id == id,
                              );
                              // pinnedQuestions.removeWhere(
                              //   (element) => element.id == id,
                              // );
                              // unpinnedQuestions.removeWhere(
                              //   (element) => element.id == id,
                              // );
                            });
                          }
                        },
                        canPin: () {
                          return true;
                        },
                        onPinToggle: (isPinned, id) async {
                          if (isPinned) {
                            // Unpin all others
                            for (var q in questions) {
                              if (q.id != id && q.isPinned) {
                                // Calls API to unpin others
                                await QuestionService().togglePin(q.id, false);
                                q.isPinned = false;
                              }
                            }
                            // State updation for the pinned one is handled by QuestionCard?
                            // Only if we setState here to reflect in list immediately if needed.
                            final index = questions.indexWhere(
                              (e) => e.id == id,
                            );
                            if (index != -1) {
                              questions[index].isPinned = true;
                            }
                          } else {
                            final index = questions.indexWhere(
                              (e) => e.id == id,
                            );
                            if (index != -1) {
                              questions[index].isPinned = false;
                            }
                          }

                          // Re-sort
                          questions.sort((a, b) {
                            if (a.isPinned && !b.isPinned) return -1;
                            if (!a.isPinned && b.isPinned) return 1;
                            final aTime = a.answeredAt ?? a.createdAt;
                            final bTime = b.answeredAt ?? b.createdAt;
                            return bTime.compareTo(aTime);
                          });
                          setState(() {});
                        },
                      ),
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
