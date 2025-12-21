import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> users = [];
  DocumentSnapshot? lastDoc;
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
    final query = widget.searchQuery.trim();

    // فاضي
    if (query.isEmpty) {
      users.clear();
      lastDoc = null;
      hasMore = false;
      setState(() {});
      return;
    }

    // @ بس
    if (query.startsWith('@') && query.length == 1) {
      users.clear();
      lastDoc = null;
      hasMore = false;
      setState(() {});
      return;
    }

    if (isLoading) return;

    if (isRefresh) {
      lastDoc = null;
      hasMore = true;
      users.clear();
    }

    if (!hasMore) return;

    setState(() => isLoading = true);

    try {
      Query query = _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          // .where('isDeleted', isEqualTo: false)
          .where('id', isNotEqualTo: MySharedPreferences.userId)
          .limit(pageSize);

      // if (widget.searchQuery.isNotEmpty) {
      //   query = query.where('name_keywords', arrayContains: widget.searchQuery);
      // }
      if (widget.searchQuery.isNotEmpty) {
        final bool isUserNameSearch = widget.searchQuery.startsWith('@');
        final String queryText = isUserNameSearch
            ? widget.searchQuery.substring(1)
            : widget.searchQuery;

        if (isUserNameSearch) {
          // البحث باسم المستخدم
          query = query
              .where('userName', isGreaterThanOrEqualTo: queryText)
              .where('userName', isLessThan: '${queryText}\uf8ff');
        } else {
          // البحث بالاسم (keywords)
          query = query.where('name_keywords', arrayContains: queryText);
        }
      }

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        lastDoc = snap.docs.last;
        users.addAll(
          snap.docs.map(
            (doc) =>
                UserModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          ),
        );
      }

      hasMore = snap.docs.length == pageSize;
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
