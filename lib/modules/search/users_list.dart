import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../shared/widgets/custom_network_image.dart';
import '../profile/view/profile_screen.dart';
import '../../shared/style/app_colors.dart';
import 'package:domandito/shared/services/follow_service.dart';
import 'package:domandito/shared/models/follow_model.dart';
import 'package:domandito/shared/services/block_service.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:svg_flutter/svg_flutter.dart';

class SearchUsersList extends StatefulWidget {
  final String searchQuery;
  const SearchUsersList({super.key, required this.searchQuery});

  @override
  State<SearchUsersList> createState() => _SearchUsersListState();
}

class _SearchUsersListState extends State<SearchUsersList> {
  final _supabase = Supabase.instance.client;

  List<UserModel> users = [];
  int _offset = 0;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchUsers(isRefresh: true);
  }

  @override
  void didUpdateWidget(covariant SearchUsersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      fetchUsers(isRefresh: true);
    }
  }

  Future<void> fetchUsers({bool isRefresh = false}) async {
    final queryText = widget.searchQuery.trim();

    // Require at least 3 characters for name search, or 2 for username search (@a)
    final minLength = queryText.startsWith('@') ? 2 : 3;
    if (queryText.length < minLength) {
      users.clear();
      _offset = 0;
      hasMore = false;
      setState(() {});
      return;
    }

    if (isLoading) return;

    if (isRefresh) {
      _offset = 0;
      hasMore = true;
      users.clear();
    }

    if (!hasMore) return;

    setState(() => isLoading = true);

    try {
      // 1. Start building the query
      PostgrestFilterBuilder query = _supabase
          .from('users')
          .select('id, name, username, image, is_verified, token');

      if (MySharedPreferences.isLoggedIn) {
        query = query.neq('id', MySharedPreferences.userId);
      }

      // 2. Apply search filters if needed
      if (queryText.isNotEmpty) {
        final bool isUserNameSearch = queryText.startsWith('@');
        final String searchText = isUserNameSearch
            ? queryText.substring(1)
            : queryText;

        if (isUserNameSearch) {
          // Using ilike for case-insensitive partial match
          query = query.ilike('username', '$searchText%');
        } else {
          // Using ilike for case-insensitive match anywhere in the name
          query = query.ilike('name', '%$searchText%');
        }
      }

      // 3. Apply sorting and pagination
      final List<dynamic> data = await query
          .order('created_at', ascending: false)
          .range(_offset, _offset + pageSize - 1);

      var newUsers = data
          .map(
            (json) => UserModel.fromJson(
              json as Map<String, dynamic>,
              json['id'].toString(),
            ),
          )
          .toList();

      // 4. Check Follow Status
      if (newUsers.isNotEmpty && MySharedPreferences.isLoggedIn) {
        final ids = newUsers.map((e) => e.id).toList();
        final followsData = await _supabase
            .from('follows')
            .select('following_id')
            .eq('follower_id', MySharedPreferences.userId)
            .filter('following_id', 'in', ids);

        final followedIds = (followsData as List)
            .map((e) => e['following_id'])
            .toSet();

        // 5. Check Block Status
        // A. Users I blocked
        final blockedIds = await BlockService.getBlockedUserIds(
          MySharedPreferences.userId,
        );

        // B. Users who blocked ME (Hide them completely)
        final whoBlockedMeIds = await BlockService.getWhoBlockedMe(
          MySharedPreferences.userId,
        );

        final myBlockedSet = blockedIds.toSet(); // Users I blocked
        final blockersSet = whoBlockedMeIds.toSet(); // Users blocking me

        // Filter out users who blocked me
        newUsers = newUsers.where((u) => !blockersSet.contains(u.id)).toList();

        newUsers = newUsers.map((u) {
          return u.copyWith(
            isFollowing: followedIds.contains(u.id),
            isBlockedByMe: myBlockedSet.contains(u.id),
          );
        }).toList();
      }

      if (isRefresh) {
        users = newUsers;
      } else {
        users.addAll(newUsers);
      }

      _offset += newUsers.length;
      hasMore = newUsers.length == pageSize;
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty && !isLoading) {
      return const Center();
    }

    return RefreshIndicator(
      color: AppColors.primary,

      onRefresh: () => fetchUsers(isRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return Center(
              child: TextButton(
                onPressed: isLoading ? null : fetchUsers,
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
            );
          }

          final user = users[index];
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              pushScreen(context, screen: ProfileScreen(userId: user.id));
            },
            child: Container(
              color: Colors.transparent,

              child: Row(
                children: [
                  CustomNetworkImage(
                    url: user.image,
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
                              user.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.isVerified)
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
                          "@${user.userName}",
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
                  // Follow Button
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user.isFollowing
                            ? Colors.grey[300]
                            : AppColors.primary,
                        foregroundColor: user.isFollowing
                            ? Colors.black
                            : Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        elevation: 0,
                      ),
                      onPressed: user.isBlockedByMe
                          ? null
                          : () async {
                              if (!MySharedPreferences.isLoggedIn) {
                                return;
                              }
                              setState(() {
                                // Optimistic update
                                users[index] = user.copyWith(
                                  isFollowing: !user.isFollowing,
                                );
                              });

                              // Call service
                              await FollowService.toggleFollow(
                                context: context,
                                me: FollowUser(
                                  id: MySharedPreferences.userId,
                                  name: MySharedPreferences.userName,
                                  image: MySharedPreferences.image,
                                  userName: MySharedPreferences.userUserName,
                                  userToken: MySharedPreferences.deviceToken,
                                ),
                                targetUser: FollowUser(
                                  id: user.id,
                                  name: user.name,
                                  image: user.image,
                                  userName: user.userName,
                                  userToken: user.token,
                                ),
                              );
                              // If logic requires verifying result, we can await and revert if false
                              // But FollowService handles toasts/errors.
                            },
                      child: Text(
                        user.isBlockedByMe
                            ? (!context.isCurrentLanguageAr()
                                  ? "Blocked"
                                  : "محظور")
                            : user.isFollowing
                            ? (!context.isCurrentLanguageAr()
                                  ? "Following"
                                  : "أتابعه")
                            : (!context.isCurrentLanguageAr()
                                  ? "Follow"
                                  : "متابعة"),
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
    );
  }
}
