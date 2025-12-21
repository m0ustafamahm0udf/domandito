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

    // فاضي
    if (queryText.isEmpty) {
      users.clear();
      _offset = 0;
      hasMore = false;
      setState(() {});
      return;
    }

    // @ بس
    if (queryText.startsWith('@') && queryText.length == 1) {
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
          .select()
          .neq('id', MySharedPreferences.userId);

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

      final newUsers = data
          .map(
            (json) => UserModel.fromJson(
              json as Map<String, dynamic>,
              json['id'].toString(),
            ),
          )
          .toList();

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
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
