// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:domandito/core/utils/shared_prefrences.dart';
// import 'package:domandito/modules/profile/view/profile_screen.dart';
// import 'package:domandito/shared/widgets/custom_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Users")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             // .where('isDeleted', isEqualTo: false) // لو عندك Soft Delete
//             // .orderBy('createdAt', descending: true) // ترتيب من الأحدث
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No users found"));
//           }

//           final users = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               final data = users[index].data() as Map<String, dynamic>;

//               return ListTile(
//                 onTap: () {
//                   if (MySharedPreferences.userId != data['id']) {
//                     pushScreen(context, screen: HomeScreen(userId: data['id']));
//                   }
//                 },
//                 leading: CustomNetworkImage(url: data['image'], radius: 999,height: 40,width: 40,),
//                 title: Text(data['name'] ?? "No Name"),
//                 subtitle: Text("@${data['userName'] ?? ''}"),
//                 trailing:  MySharedPreferences.userId == data['id'] ? const Text("You") : null,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/search/search.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/shared/models/follow_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg_flutter.dart';
import '../../../shared/widgets/q_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

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
    getQuestions();
    fetchFollowing();
  }

  Future<void> getQuestions() async {
    // منع استدعاءات متزامنة أو لو مفيش بيانات إضافية
    if (isQuestionsLoading || !hasMore) return;

    setState(() => isQuestionsLoading = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('questions')
          .where('isAnonymous', isEqualTo: false)
          .where('sender.id', isEqualTo: MySharedPreferences.userId)
          .where('isDeleted', isEqualTo: false)
          .where('answeredAt', isNull: false)
          .orderBy('answeredAt', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      // .collection('questions')
      // .where('receiver.id', isEqualTo: MySharedPreferences.userId)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Domandito',
          style: TextStyle(fontSize: 36, fontFamily: 'Dancing_Script'),
        ),
        leading: !MySharedPreferences.isLoggedIn
            ? IconButton.filled(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.white),
                ),
                onPressed: () {
                  // MySharedPreferences.clearProfile(context: context);
                  // context.toAndRemoveAll(SignInScreen());
                  pushReplacementWithoutNavBar(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                icon: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SvgPicture.asset(
                    AppIcons.logout,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
        actions: [
          if (following.isEmpty && !isLoadingF)
            IconButton.filled(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.white),
              ),
              onPressed: () => pushScreen(context, screen: SearchUsersScreen()),
              icon: SvgPicture.asset(
                AppIcons.searchIcon,
                color: AppColors.primary,
              ),
            ),
          SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator.adaptive(
        color: AppColors.primary,

        onRefresh: () async {
          lastDoc = null;
          hasMore = true;
          questions.clear();

          lastFDoc = null;
          hasMoreF = true;
          following.clear();
          Future.wait([getQuestions(), fetchFollowing()]);

          setState(() {});
        },
        child: ListView(
          padding: EdgeInsets.only(top: 10, right: 16, left: 16),

          children: [
            followingList(),
            SizedBox(height: 5),

            // const SizedBox(height: 2),
            questions.isEmpty && !isQuestionsLoading
                ? SizedBox(
                    height: following.isEmpty
                        ? MediaQuery.of(context).size.height * 0.7
                        : MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LogoWidg(),
                          if (MySharedPreferences.isLoggedIn)
                            Text(
                              !context.isCurrentLanguageAr()
                                  ? 'You have not asked any questions yet'
                                  : 'لم تقم بإرسال أي أسئلة بعد',
                              style: TextStyle(
                                color: AppColors.black,
                                // fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          if (!MySharedPreferences.isLoggedIn)
                            TextButton.icon(
                              iconAlignment: IconAlignment.end,
                              onPressed: () => pushScreen(
                                context,
                                screen: SearchUsersScreen(),
                              ),
                              icon: SvgPicture.asset(
                                AppIcons.searchIcon,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                !context.isCurrentLanguageAr()
                                    ? 'Add friends'
                                    : 'إبدأ بإضافة أصدقاء',
                                style: TextStyle(
                                  color: AppColors.black,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // child: Center(
                    //   child: TextButton.icon(
                    //     iconAlignment: IconAlignment.end,
                    //     onPressed: () =>
                    //         pushScreen(context, screen: SearchUsersScreen()),
                    //     icon: SvgPicture.asset(
                    //       AppIcons.searchIcon,
                    //       color: AppColors.primary,
                    //     ),
                    //     label: Text(
                    //       'إبدأ بإضافة أصدقاء',
                    //       style: TextStyle(
                    //         color: AppColors.primary,
                    //         // fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  )
                : questionsWidget(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Builder(
                  builder: (context) {
                    if (!hasMore && questions.isNotEmpty) {
                      return SizedBox();
                    }
                    if (isQuestionsLoading) {
                      return SizedBox(
                        height: context.h * 0.75,

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
                        !context.isCurrentLanguageAr() ? "Load more" : "المزيد",
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchFollowing({bool isRefresh = false}) async {
    if (isLoadingF) return;

    if (isRefresh) {
      lastFDoc = null;
      hasMoreF = true;
      following.clear();
    }

    if (!hasMoreF) return;

    setState(() => isLoadingF = true);

    try {
      Query query = _firestore
          .collection('follows')
          .where('me.id', isEqualTo: MySharedPreferences.userId)
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (lastFDoc != null) {
        query = query.startAfterDocument(lastFDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        lastFDoc = snap.docs.last;
        following.addAll(
          snap.docs
              .map((e) => e.data())
              .whereType<Map<String, dynamic>>()
              .map((data) => FollowModel.fromJson(data)),
        );
      }

      hasMoreF = snap.docs.length == pageSize;
    } catch (e) {
      debugPrint('Error fetching following: $e');
    } finally {
      setState(() => isLoadingF = false);
    }
  }

  List<FollowModel> following = [];
  DocumentSnapshot? lastFDoc;
  bool isLoadingF = false;
  bool hasMoreF = true;
  final int pageSize = 10;

  Widget followingList() {
    return SizedBox(
      height: following.isEmpty
          ? 0
          : isLoadingF
          ? 0
          : 100,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: following.length + (hasMoreF ? 1 : 0),

              separatorBuilder: (context, index) => SizedBox(width: 10),
              scrollDirection: Axis.horizontal,

              itemBuilder: (context, index) {
                if (index == following.length) {
                  // زر تحميل المزيد
                  return TextButton(
                    onPressed: isLoadingF ? null : fetchFollowing,
                    child: isLoadingF
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CupertinoActivityIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            !context.isCurrentLanguageAr()
                                ? "Load more"
                                : "المزيد",
                          ),
                  );
                }
                final f = following[index];

                return FadeIn(
                  child: GestureDetector(
                    onTap: () {
                      pushScreen(
                        context,
                        screen: ProfileScreen(
                          userId: f.targetUser.id,
                          onUnfollow: (res) {
                            if (res) {
                              setState(() {
                                following.removeAt(index);
                              });
                            }
                          },
                        ),
                      ).then((value) async {
                        // await fetchFollowing(isRefresh: true);
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: .5,
                            ),
                          ),
                          child: CustomNetworkImage(
                            url: f.targetUser.image,
                            radius: 999,
                            height: 58,
                            width: 58,
                          ),
                        ),
                        SizedBox(height: 5),
                        SizedBox(
                          width: 60,
                          child: Text(
                            f.targetUser.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Directionality(
                        //   textDirection: TextDirection.ltr,
                        //   child: Text(
                        //     "@${f.targetUser.userName}",
                        //     maxLines: 1,
                        //     style: const TextStyle(fontSize: 10, color: Colors.grey),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (following.isNotEmpty)
            Transform.translate(
              offset: const Offset(0, 10),
              child: IconButton.filled(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                ),
                onPressed: () =>
                    pushScreen(context, screen: SearchUsersScreen()),
                icon: SvgPicture.asset(
                  AppIcons.searchIcon,
                  color: AppColors.white,
                ),
              ),
            ),
        ],
      ),
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

        return QuestionCard(
          receiverToken: '',

          currentProfileUserId: q.receiver.id,
          isInProfileScreen: false,
          question: q,
          receiverImage: q.receiver.image,
        );
      },
    );
  }
}
