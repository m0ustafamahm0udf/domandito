import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/notifications/models/notification_model.dart';
import 'package:domandito/modules/notifications/repositories/notifications_repository.dart';
import 'package:domandito/modules/notifications/widgets/notification_card.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/services/badge_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  final NotificationsRepository _repository = NotificationsRepository();
  List<NotificationModel> notifications = [];
  bool isNotificationsLoading = false;
  bool isMoreLoading = false;
  bool hasMore = true;
  int _offset = 0;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    getNotifications();
    BadgeService.updateBadgeCount();
  }

  Future<void> getNotifications({bool isLoadMore = false}) async {
    if (isNotificationsLoading || isMoreLoading || !hasMore) return;

    if (isLoadMore) {
      setState(() => isMoreLoading = true);
    } else {
      setState(() => isNotificationsLoading = true);
    }

    try {
      int page = (_offset / limit).floor();

      final newNotifications = await _repository.fetchNotifications(
        page: page,
        limit: limit,
      );

      if (newNotifications.isEmpty) {
        hasMore = false;
        if (isLoadMore) {
          setState(() => isMoreLoading = false);
        } else {
          setState(() => isNotificationsLoading = false);
        }
        return;
      }

      if (newNotifications.length < limit) {
        hasMore = false;
      } else {
        hasMore = true;
      }

      for (var n in newNotifications) {
        if (!notifications.any((e) => e.id == n.id)) {
          notifications.add(n);
        }
      }

      _offset += newNotifications.length;
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      if (isLoadMore) {
        setState(() => isMoreLoading = false);
      } else {
        setState(() => isNotificationsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          !context.isCurrentLanguageAr() ? 'Notifications' : 'الإشعارات',
          style: TextStyle(
            fontFamily: context.isCurrentLanguageAr()
                ? 'Rubik'
                : 'Dancing_Script',
          ),
        ),
      ),
      body: SafeArea(
        child: isNotificationsLoading
            ? const Center(
                child: CupertinoActivityIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      color: AppColors.primary,
                      onRefresh: () async {
                        _offset = 0;
                        hasMore = true;
                        notifications.clear();
                        await getNotifications();
                        BadgeService.updateBadgeCount();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,

                          vertical: 10,
                        ),
                        itemCount: notifications.length + 1,
                        // separatorBuilder: (context, index) =>
                        //     const Divider(thickness: .1, color: Colors.grey),
                        itemBuilder: (context, index) {
                          // ----------- Empty State -----------
                          if (notifications.isEmpty &&
                              index == 0 &&
                              !isNotificationsLoading) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const LogoWidg(),
                                    Text(
                                      !context.isCurrentLanguageAr()
                                          ? "No notifications"
                                          : "لا توجد اشعارات",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // ----------- Load More Button -----------
                          if (index == notifications.length) {
                            if (notifications.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            if (isMoreLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }

                            if (!hasMore) return const SizedBox(height: 10);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await getNotifications(isLoadMore: true);
                                  },
                                  child: Text(
                                    !context.isCurrentLanguageAr()
                                        ? "Load More"
                                        : "المزيد",
                                  ),
                                ),
                              ),
                            );
                          }

                          // ----------- Notification Item -----------
                          final notification = notifications[index];
                          return NotificationCard(
                            notificationsData: notification,
                            onRemove: () {
                              setState(() {
                                notifications.removeAt(index);
                              });
                            },
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
