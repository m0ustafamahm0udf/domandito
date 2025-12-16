import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/constants/app_platforms_serv.dart';
import 'package:domandito/core/services/file_picker_service.dart';
import 'package:domandito/core/services/get_device_serv.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/account/views/account_screen.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/ask/views/ask_question_screen.dart';
import 'package:domandito/modules/following/views/following_screen.dart';
import 'package:domandito/shared/apis/upload_images_services.dart';
import 'package:domandito/shared/models/follow_model.dart';
import 'package:domandito/shared/services/follow_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_bounce_button.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/image_view_screen.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:domandito/shared/widgets/share_widget.dart';
import 'package:domandito/shared/widgets/show_image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg_flutter.dart';
import '../../../shared/widgets/q_card.dart';
import '../../signin/models/user_model.dart';

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
  DocumentSnapshot? lastDoc;
  int limit = 10;
  bool isFollowing = false;
  bool followLoading = false;
  int totalQuestionsCount = 0;

  @override
  void initState() {
    super.initState();
    isMe = widget.userId == MySharedPreferences.userId;
    getProfile();
    getQuestionsCount();
    checkFollowing();
    getQuestions();
  }

  Future<void> getProfile() async {
    setState(() => isLoading = true);
    try {
      if (widget.userId.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
        if (doc.exists) {
          user = UserModel.fromFirestore(doc);
          if (isMe) {
            canAskedAnonymously = user!.canAskedAnonymously;
            // log('canAskedAnonymously $canAskedAnonymously');
            MySharedPreferences.userName = user!.name;
            MySharedPreferences.userUserName = user!.userName;
            MySharedPreferences.phone = user!.phone;
            MySharedPreferences.bio = user!.bio;
            MySharedPreferences.email = user!.email;
            MySharedPreferences.image = user!.image;
            MySharedPreferences.isVerified = user!.isVerified;
          }
          // await getQuestionsCount();
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
      final countQuery = await FirebaseFirestore.instance
          .collection('questions')
          .where('receiver.id', isEqualTo: widget.userId)
          .where('isDeleted', isEqualTo: false)
          .where('answeredAt', isNull: false)
          .count() // <-- Aggregation
          .get();

      totalQuestionsCount = countQuery.count ?? 0;
      setState(() {});

      debugPrint("Total questions count: $totalQuestionsCount");
    } catch (e) {
      debugPrint("Error getting questions count: $e");
    }
  }

  Future<void> getQuestions() async {
    // منع استدعاءات متزامنة أو لو مفيش بيانات إضافية
    if (isQuestionsLoading || !hasMore) return;

    setState(() => isQuestionsLoading = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('questions')
          .where('receiver.id', isEqualTo: widget.userId)
          .where('isDeleted', isEqualTo: false)
          .where('answeredAt', isNull: false)
          .orderBy('answeredAt', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // if (isMe) {
      //   log("isMe");
      //   query = query
      //       .where('sender.id', isEqualTo: widget.userId)
      //       .where('isAnonymous', isEqualTo: false);
      // }
      // .collection('questions')
      // .where('receiver.id', isEqualTo: widget.userId)
      // .where('isDeleted', isEqualTo: false)
      // .where('answeredAt', isNull: false)
      // .orderBy('answeredAt', descending: true)
      // .orderBy('createdAt', descending: true)
      // .limit(limit);

      // ابدأ من آخر مستند لو موجود
      if (lastDoc != null) query = query.startAfterDocument(lastDoc!);

      final querySnap = await query.get();

      // لو مفيش داتا جديدة
      if (querySnap.docs.isEmpty) {
        hasMore = false;
        return;
      }

      // لو عدد الدوكز أقل من اللِيمت يبقى مفيش المزيد بعد كده
      hasMore = querySnap.docs.length == limit;

      // أضف الأسئلة بدون تكرار — مهم لو حصل reload أو call متكرر
      for (var doc in querySnap.docs) {
        // ضمّ doc.id داخل البيانات قبل تحويلها للموديل
        final qData = doc.data() as Map<String, dynamic>;
        qData['id'] = doc.id;

        final q = QuestionModel.fromJson(qData);
        final exists = questions.any((element) => element.id == q.id);
        if (!exists) questions.add(q);
      }

      // احفظ آخر مستند للـ pagination
      lastDoc = querySnap.docs.last;
    } catch (e, st) {
      debugPrint("Error loading questions: $e\n$st");
      // لو Firestore طالب index غالبًا هيطبع استثناء فيه رابط في الـ log — شوف اللوق لو ظهر.
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
      await FirebaseFirestore.instance.collection('questions').doc(id).update({
        'answeredAt': null,
        'answerText': null,
        'images': [],
      });
      await getQuestionsCount();

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

  Future<void> _pickImage(ImageSource source) async {
    AppConstance().showLoading(context);

    try {
      final pickedFilePath = await ImagePickerService.pickFile(
        source: source,
        type: FileType.image,
      );
      if (pickedFilePath != null) {
        final url = await UploadImagesToS3Api().uploadFiles(
          filePath: pickedFilePath,
          fileName:
              '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.png',
          destinationPath: 'profiles/${MySharedPreferences.userId}',
        );
        if (url.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(MySharedPreferences.userId)
              .update({'image': url})
              .then((value) async {
                // Loader.hide();
                AppConstance().showSuccesToast(
                  context,
                  msg: !context.isCurrentLanguageAr()
                      ? 'Updated successfully'
                      : 'تم التعديل',
                );
                setState(() {
                  MySharedPreferences.image = url;
                });
                Loader.hide();
                user!.image = url;
                setState(() {});
                // context.backWithValue(true);
              });
        } else {
          Loader.hide();
          AppConstance().showErrorToast(
            context,
            msg: !context.isCurrentLanguageAr()
                ? 'Error uploading image'
                : 'حدث خطاء يرجى المحاولة لاحقا',
          );
        }
      } else {
        Loader.hide();
      }
    } catch (e) {
      Loader.hide();

      // log("Error picking image: $e");
    }
  }

  bool canAskedAnonymously = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppbar(context),
      body: isLoading
          ? Center(child: CupertinoActivityIndicator(color: AppColors.primary))
          : user == null
          ? const Center(child: Text(''))
          : RefreshIndicator.adaptive(
              color: AppColors.primary,

              onRefresh: () async {
                lastDoc = null;
                hasMore = true;
                questions.clear();
                await getProfile();
                await getQuestions();
                await getQuestionsCount();
                setState(() {});
              },
              child: ListView(
                padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                children: [
                  profileImage(context),

                  // const SizedBox(height: 0),
                  nameWidget(),
                  const SizedBox(height: 5),

                  userNameWidget(),

                  // if (user!.bio.isNotEmpty) const SizedBox(height: 5),
                  // if (user!.bio.isNotEmpty)
                  //   Center(
                  //     child: Text(
                  //       user!.bio,
                  //       style: const TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 12,

                  //         // fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  const SizedBox(height: 15),

                  folooingCount(context),

                  const SizedBox(height: 15),

                  askAndFollow(context),
                  const SizedBox(height: 4),
                  if (isMe)
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      value: canAskedAnonymously,
                      onChanged: (value) async {
                        AppConstance().showLoading(context);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(MySharedPreferences.userId)
                            .update({'canAskedAnonymously': value})
                            .then((_) {
                              setState(() {
                                canAskedAnonymously = value;

                                /// تحديث sender في الكارد
                                user?.canAskedAnonymously = value;
                              });
                              AppConstance().showSuccesToast(
                                context,
                                msg: !context.isCurrentLanguageAr()
                                    ? 'Updated successfully'
                                    : 'تم التعديل',
                              );
                              Loader.hide();
                            })
                            .onError((error, stackTrace) {
                              AppConstance().showErrorToast(
                                context,
                                msg: !context.isCurrentLanguageAr()
                                    ? 'Error updating'
                                    : 'حدث خطاء يرجى المحاولة لاحقا',
                              );
                              Loader.hide();
                            });
                      },
                      title: Text(
                        !context.isCurrentLanguageAr()
                            ? 'Receive questions from anonymous users'
                            : 'إستقبال أسئلة من مستخدمين مجهولين',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(thickness: 0.1, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),

                  // Text(
                  //   'آخر المستجدات',
                  //   style: const TextStyle(
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // --- قائمة الأسئلة ---
                  questions.isEmpty && !isQuestionsLoading
                      ? Center(
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
                      : questionsWidget(),

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

  Center userNameWidget() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '@${user!.userName}',
            textDirection: TextDirection.ltr,

            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          // if(MySharedPreferences.userId == widget.userId)
          // SizedBox(
          //   height: 35,
          //   width: 35,
          //   child: ShareWidget(userUserName: user?.userName ?? '', questionId: '')),
        ],
      ),
    );
  }

  Row nameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text(
          user!.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (user!.isVerified) const SizedBox(width: 2),
        if (user!.isVerified)
          SvgPicture.asset(
            AppIcons.verified,
            height: 20,
            width: 20,
            color: AppColors.primary,
          ),
      ],
    );
  }

  ListView questionsWidget() {
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
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                await deleteQuestion(q.id);
                setState(() {
                  questions.removeAt(index);
                });
              }
              return;
            },

            child: QuestionCard(
              receiverToken: user!.token,
              currentProfileUserId: user!.id,

              question: q,
              receiverImage: user!.image,
            ),
          );
        }
        return QuestionCard(
          receiverToken: user!.token,

          currentProfileUserId: user!.id,

          question: q,
          receiverImage: user!.image,
        );
      },
    );
  }

  Row askAndFollow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BounceButton(
            gradient: LinearGradient(
              colors: [AppColors.primary, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: SvgPicture.asset(
              AppIcons.anonymous,
              height: 25,
              color: AppColors.white,
            ),
            radius: 60,
            height: 55,
            onPressed: () {
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
              // log(user!.userName);
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
            title: isMe
                ? !context.isCurrentLanguageAr()
                      ? 'Ask yourself'
                      : 'إسأل نفسك'
                : !context.isCurrentLanguageAr()
                ? 'Ask'
                : 'إسأل',
            textSize: 18,
            // padding: 20,
          ),
        ),
        if (!isMe) SizedBox(width: 10),
        if (!isMe)
          Expanded(
            child: BounceButton(
              isOutline: !isFollowing,
              gradient: !isFollowing
                  ? null
                  : LinearGradient(
                      colors: [AppColors.primary, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              icon: SvgPicture.asset(
                AppIcons.anonymous,
                height: 25,
                color: isFollowing ? AppColors.white : AppColors.primary,
              ),
              radius: 60,
              height: 55,
              onPressed: () async {
                if (!followLoading) {
                  await toggleFollowAction();
                } else {
                  null;
                }
              },
              title: followLoading
                  ? ''
                  : isFollowing
                  ? !context.isCurrentLanguageAr()
                        ? 'Unfollow'
                        : "إلغاء المتابعة"
                  : !context.isCurrentLanguageAr()
                  ? 'Follow'
                  : "متابعة",
              textSize: 18,
              child: followLoading
                  ? const Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CupertinoActivityIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  Center folooingCount(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                formatNumber(user!.followersCount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Dancing_Script',
                ),
              ),
              Text(
                !context.isCurrentLanguageAr() ? 'Followers' : 'المتابعين',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              // height: 20,
              width: 0,
              color: AppColors.primary,
              thickness: 1,
            ),
          ),
          GestureDetector(
            onTap: () {
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
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    formatNumber(user!.followingCount),

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Dancing_Script',
                    ),
                  ),
                  Text(
                    !context.isCurrentLanguageAr()
                        ? 'Following'
                        : isMe
                        ? 'أتابع'
                        : 'يتابع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              // height: 20,
              width: 0,
              color: AppColors.primary,
              thickness: 1,
            ),
          ),
          GestureDetector(
            onTap: () {
              // if (MySharedPreferences.userId == user!.id) {
              //   context.read<LandingCubit>().controller.jumpToTab(0);
              // }
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    formatNumber(totalQuestionsCount),

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Dancing_Script',
                    ),
                  ),
                  Text(
                    !context.isCurrentLanguageAr() ? 'Questions' : 'الأسئلة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stack profileImage(BuildContext context) {
    final platform = PlatformService.platform;

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w * 0.22,
            vertical: 6,
          ),
          child: GestureDetector(
            onTap: () => pushScreen(
              context,
              screen: ImageViewScreen(
                images: [user!.image],
                title: '',
                onBack: (i) {},
              ),
            ),
            child: Container(
              height: 175,
              width: 175,
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: ClipOval(
                child: CustomNetworkImage(
                  radius: 999,
                  url: user!.image,
                  height: 175,
                  width: 175,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        if (isMe)
          if (AppPlatform.webAndroid != platform &&
              AppPlatform.webIOS != platform &&
              AppPlatform.webDesktop != platform)
            Positioned(
              top: 20,
              left: context.w * 0.24,
              child: Container(
                // padding: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  color: AppColors.white,

                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async {
                    final source = await showModalBottomSheet<ImageSource>(
                      useRootNavigator: true,
                      routeSettings: RouteSettings(name: 'ImagePickerSheet'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppConstance.radiusBig),
                          topRight: Radius.circular(AppConstance.radiusBig),
                        ),
                      ),
                      context: context,
                      builder: (BuildContext context) =>
                          const ImagePickerSheet(),
                    );

                    if (source != null) {
                      await _pickImage(source);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      AppColors.primary,
                    ),
                  ),
                  icon: Icon(Icons.edit, color: AppColors.white),
                ),
              ),
            ),
      ],
    );
  }

  AppBar profileAppbar(BuildContext context) {
    return AppBar(
      title: Text(
        '@${user?.userName ?? ''}',
        textDirection: TextDirection.ltr,

        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'Dancing_Script',
        ),
      ),

      actions: [
        // if (isMe)
        //   IconButton.filled(
        //     onPressed: () {
        //       pushScreen(context, screen: const EditProfileScreen()).then((
        //         value,
        //       ) async {
        //         if (value == true) {
        //           lastDoc = null;
        //           hasMore = true;
        //           questions.clear();
        //           await getProfile();
        //           await getQuestions();
        //           await getQuestionsCount();

        //           setState(() {});
        //         }
        //       });
        //     },
        //     icon: Icon(Icons.edit),
        //   )
        // else
        // if (MySharedPreferences.userId != user?.id)
        ShareWidget(userUserName: user?.userName ?? '', questionId: ''),
        // else
        // IconButton.filled(onPressed: () {
        //   pushScreen(context, screen: AccountScreen());
        // }, icon: Icon(Icons.more_vert)),
        SizedBox(width: 4),

        // const SizedBox(width: 5),
      ],
      leading: isMe
          ? IconButton.filled(
              onPressed: () {
                pushScreen(context, screen: AccountScreen());
              },
              icon: Icon(Icons.more_vert),
            )
          // ? IconButton.filled(
          //     onPressed: () async {
          //       final rest = await showLogOutButtomSheet(
          //         isDelete: false,
          //         context: context,
          //       );
          //       if (rest != null && rest) {
          //         MySharedPreferences.clearProfile(context: context);
          //       }
          //     },
          //     icon: Transform.flip(
          //       flipX: true,
          //       child: SvgPicture.asset(
          //         AppIcons.logout,
          //         color: AppColors.primary,
          //       ),
          //     ),
          //   )
          : IconButton.filled(
              onPressed: () => context.back(),
              icon: Icon(Icons.arrow_back),
            ),
    );
  }
}
