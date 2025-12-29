import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/notifications/models/notification_model.dart';
import 'package:domandito/modules/notifications/repositories/notifications_repository.dart';
import 'package:domandito/modules/notifications/widgets/notification_card.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/services/badge_service.dart';
import 'package:domandito/shared/widgets/custom_dialog.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';

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
  bool _isMarkingAllAsRead = false;

  @override
  void initState() {
    super.initState();
    getNotifications();
    BadgeService.updateBadgeCount();
  }

  Future<void> getNotifications({bool isLoadMore = false}) async {
    // ... existing implementation
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

  Future<bool> _deleteNotification(String id, int index) async {
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
      await _repository.deleteNotification(id);

      AppConstance().showSuccesToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Notification deleted successfully'
            : 'تم حذف الإشعار بنجاح',
      );

      if (mounted) {
        setState(() {
          notifications.removeAt(index);
        });
      }
      return true;
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Error deleting notification'
            : 'حدث خطأ أثناء الحذف',
      );
      return false;
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isMarkingAllAsRead) return;

    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }

    setState(() => _isMarkingAllAsRead = true);

    try {
      // Call Supabase RPC to mark all notifications as read
      final result = await Supabase.instance.client.rpc(
        'mark_all_notifications_read',
        params: {'p_user_id': MySharedPreferences.userId},
      );

      final updatedCount = result as int;

      if (updatedCount > 0) {
        // Refresh notifications list to get updated data
        _offset = 0;
        hasMore = true;
        notifications.clear();
        await getNotifications();

        // Update badge count
        BadgeService.updateBadgeCount();

        AppConstance().showSuccesToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'All notifications marked as read'
              : 'تم قراءة جميع الإشعارات',
        );
      } else {
        AppConstance().showInfoToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'No unread notifications'
              : 'لا توجد إشعارات غير مقروءة',
        );
      }
    } catch (e) {
      debugPrint("Error marking all as read: $e");
      AppConstance().showErrorToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Error marking notifications as read'
            : 'حدث خطأ أثناء قراءة الإشعارات',
      );
    } finally {
      setState(() => _isMarkingAllAsRead = false);
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
            fontSize: 32,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            _isMarkingAllAsRead
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CupertinoActivityIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.done_all),
                    tooltip: !context.isCurrentLanguageAr()
                        ? 'Mark all as read'
                        : 'وضع علامة مقروء على الكل',
                    onPressed: _markAllAsRead,
                  ),
        ],
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
                          return Dismissible(
                            key: ValueKey(notification.id),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        !context.isCurrentLanguageAr()
                                            ? "Delete"
                                            : "حذف",
                                        style: const TextStyle(
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
                                      ? 'Delete Notification'
                                      : 'حذف الإشعار',
                                  onConfirm: () {},
                                  content: !context.isCurrentLanguageAr()
                                      ? 'Are you sure you want to delete this notification?'
                                      : 'هل  انت متاكد من حذف الإشعار؟',
                                ),
                              );
                              if (res == true) {
                                return await _deleteNotification(
                                  notification.id,
                                  index,
                                );
                              }
                              return false;
                            },
                            child: NotificationCard(
                              notificationsData: notification,
                              onRemove: () {
                                setState(() {
                                  notifications.removeAt(index);
                                });
                              },
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
