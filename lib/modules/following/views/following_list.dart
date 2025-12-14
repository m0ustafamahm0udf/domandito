import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/search/search.dart';
import 'package:domandito/shared/models/follow_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg.dart';

class FollowingList extends StatefulWidget {
  final Function(int)? followingCount;
  final Function? onBack;
  const FollowingList({super.key, this.followingCount, this.onBack});

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FollowModel> following = [];
  DocumentSnapshot? lastDoc;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchFollowing();
  }

  /// جلب البيانات مع الباجينيشن
  Future<void> fetchFollowing({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      lastDoc = null;
      hasMore = true;
      following.clear();
    }

    if (!hasMore) return;

    setState(() => isLoading = true);

    try {
      Query query = _firestore
          .collection('follows')
          .where('me.id', isEqualTo: MySharedPreferences.userId)
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        lastDoc = snap.docs.last;
        following.addAll(
          snap.docs
              .map((e) => e.data())
              .whereType<Map<String, dynamic>>()
              .map((data) => FollowModel.fromJson(data)),
        );
      }

      hasMore = snap.docs.length == pageSize;
    } catch (e) {
      debugPrint('Error fetching following: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,

        child: Center(
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CupertinoActivityIndicator(color: AppColors.primary),
          ),
        ),
      );
    }
    if (following.isEmpty) {
      return Expanded(
        child: SizedBox(
          child: RefreshIndicator.adaptive(
            color: AppColors.primary,
            onRefresh: () => fetchFollowing(isRefresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,


                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                            LogoWidg(),

                        TextButton.icon(
                          iconAlignment: IconAlignment.end,
                          onPressed: () =>
                              pushScreen(context, screen: SearchUsersScreen()),
                          icon: SvgPicture.asset(
                            AppIcons.searchIcon,
                            color: AppColors.primary,
                          ),
                          label: Text(
                         !context.isCurrentLanguageAr()? 'Add friends' :  'إبدأ بإضافة أصدقاء',
                            style: TextStyle(
                              color: AppColors.primary,
                              // fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      onPopInvoked: (didPop) {
        widget.followingCount!(following.length);
      },
      child: Expanded(
        child: SizedBox(
          child: RefreshIndicator.adaptive(
            color: AppColors.primary,

            onRefresh: () => fetchFollowing(isRefresh: true),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstance.hPaddingTiny,
                vertical: 0,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              // shrinkWrap: true,
              itemCount: following.length + (hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == following.length) {
                  // زر تحميل المزيد
                  return SizedBox(
                    height: context.h - AppConstance.hPadding * 12,
                    child: Center(
                      child: TextButton(
                        onPressed: isLoading ? null : fetchFollowing,
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CupertinoActivityIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            :  Text( !context.isCurrentLanguageAr()? "Load more" : "المزيد"),
                      ),
                    ),
                  );
                }

                final f = following[index];
                return GestureDetector(
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
                      await fetchFollowing(isRefresh: true);
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        CustomNetworkImage(
                          url: f.targetUser.image,
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
                                f.targetUser.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "@${f.targetUser.userName}",
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
