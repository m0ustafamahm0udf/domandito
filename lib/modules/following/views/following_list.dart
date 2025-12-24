import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/search/search.dart';
import 'package:domandito/shared/models/follow_model.dart';
import 'package:domandito/shared/services/block_service.dart';
import 'package:domandito/shared/services/follow_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg.dart';

class FollowingList extends StatefulWidget {
  // final Function(int)? followingCount;
  final Function? onBack;
  const FollowingList({super.key, this.onBack});

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<FollowModel> following = [];
  int _offset = 0;
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
      _offset = 0;
      hasMore = true;
      following.clear();
    }

    if (!hasMore) return;

    setState(() => isLoading = true);

    try {
      final query = _supabase
          .from('follows')
          .select(
            '*, targetUser:following_id(id, name, username, image, is_verified)',
          )
          .eq('follower_id', MySharedPreferences.userId)
          .order('created_at', ascending: false)
          .range(_offset, _offset + pageSize - 1);

      final List<dynamic> data = await query;

      if (data.isNotEmpty) {
        // Fetch users I blocked
        final blocks = await BlockService.getBlockedUserIds(
          MySharedPreferences.userId,
        );

        final newFollowing = data
            .map((json) => FollowModel.fromJson(json))
            .where(
              (f) => !blocks.contains(f.targetUser.id),
            ) // Filter blocked users
            .toList();
        following.addAll(newFollowing);

        _offset += data.length;
      }

      hasMore = data.length == pageSize;
    } catch (e) {
      debugPrint('Error fetching following: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && following.isEmpty) {
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
                            !context.isCurrentLanguageAr()
                                ? 'Add friends'
                                : 'إبدأ بإضافة أصدقاء',
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
        // if (widget.followingCount != null) {
        //   widget.followingCount!(following.length);
        // }
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
                            : Text(
                                !context.isCurrentLanguageAr()
                                    ? "Load more"
                                    : "المزيد",
                              ),
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
                          height: 50,
                          width: 50,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    f.targetUser.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (f.targetUser.isVerified)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: SvgPicture.asset(
                                        AppIcons.verified,
                                        height: 14,
                                        width: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
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
                        // Unfollow Button
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final res = await FollowService.toggleFollow(
                                context: context,
                                me: FollowUser(
                                  id: MySharedPreferences.userId,
                                  name: MySharedPreferences.userName,
                                  image: MySharedPreferences.image,
                                  userName: MySharedPreferences.userUserName,
                                  userToken: MySharedPreferences.deviceToken,
                                ),
                                targetUser: f.targetUser,
                              );
                              // If res is false, it means we unfollowed
                              if (!res) {
                                setState(() {
                                  following.remove(f);
                                });
                              }
                            },
                            child: Text(
                              !context.isCurrentLanguageAr()
                                  ? "Following"
                                  : "أتابعه",
                              style: TextStyle(fontSize: 12),
                            ),
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
