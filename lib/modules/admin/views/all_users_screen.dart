import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/signin/models/user_model.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svg_flutter/svg.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<UserModel> users = [];
  int _offset = 0;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 20;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      _offset = 0;
      hasMore = true;
      users.clear();
    }

    if (!hasMore) return;

    setState(() => isLoading = true);

    try {
      final List<dynamic> data = await _supabase
          .from('users') // Changed from 'user' to 'users'
          .select('id, name, username, image, is_verified, created_at')
          .range(_offset, _offset + pageSize - 1)
          .order('created_at', ascending: false);

      if (data.isNotEmpty) {
        final newUsers = data.map((json) => UserModel.fromMap(json)).toList();
        users.addAll(newUsers);
        _offset += newUsers.length;
      }

      hasMore = data.length == pageSize;
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        leading: IconButton(
          onPressed: () => context.back(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          color: AppColors.primary,
          onRefresh: () => fetchUsers(isRefresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == users.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: hasMore
                        ? (isLoading
                              ? const CupertinoActivityIndicator(
                                  color: AppColors.primary,
                                )
                              : TextButton(
                                  onPressed: fetchUsers,
                                  child: const Text("Load more"),
                                ))
                        : const SizedBox(),
                  ),
                );
              }

              final user = users[index];
              return GestureDetector(
                onTap: () {
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (user.isVerified) ...[
                                  const SizedBox(width: 4),
                                  SvgPicture.asset(
                                    AppIcons.verified,
                                    height: 16,
                                    width: 16,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              "@${user.userName}",
                              textDirection: TextDirection.ltr,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeAgo(user.createdAt, context),
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
    );
  }
}
