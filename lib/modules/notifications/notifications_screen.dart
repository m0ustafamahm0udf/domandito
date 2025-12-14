// import 'dart:developer';

import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/modules/notifications/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/notifications/widgets/notification_card.dart';

import '../../shared/widgets/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', whereIn: [MySharedPreferences.userId, 'all'])
          .orderBy('createdAt', descending: true)
          .limit(_limit);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        final newNotifications = querySnapshot.docs
            .map(
              (doc) => NotificationModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();

        setState(() {
          _notifications.addAll(newNotifications);
          if (newNotifications.length < _limit) {
            _hasMore = false;
          }
        });
      } else {
        setState(() => _hasMore = false);
      }
    } catch (e) {
      // log('Error fetching notifications: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(!context.isCurrentLanguageAr()? 'Notifications' : 'الإشعارات')),
      //   floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     FirebaseFirestore.instance.collection('notifications').add({
      //       'objectId': 'dmgMDuX9yhUamf2iZcg3',
      //       'id': '1',
      //       'createdAt': Timestamp.now(),
      //       'title': 'title',
      //       'message': 'message',
      //       'type': '',
      //       'actionUrl': '',
      //       'userId': MySharedPreferences.userId,
      //     });
      //   },
      // ),
      body: SafeArea(
        child: Column(
          children: [
            // CustomAppbar(title: 'الإشعارات',isBack: false,),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    const Divider(thickness: .1, color: Colors.grey),
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstance.hPaddingBig,
                ),
                itemCount: _notifications.length + 1,
                itemBuilder: (context, index) {
                  if (_notifications.isEmpty && !_isLoading) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child:  Center(
                        child: Text(
                         !context.isCurrentLanguageAr()? "No notifications" : "لا توجد اشعارات",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }
                  if (index < _notifications.length) {
                    final notification = _notifications[index];
                    return NotificationCard(notificationsData: notification);
                  } else {
                    if (_hasMore) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: () => _fetchNotifications(loadMore: true),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: LoadingWidget(),
                                )
                              : Text( !context.isCurrentLanguageAr()? 'Load more' : 'المزيد'),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
