import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domandito/modules/notifications/models/notification_model.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';

class NotificationsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NotificationModel>> fetchNotifications({
    required int page,
    required int limit,
  }) async {
    final offset = page * limit;

    try {
      final response = await _client.rpc(
        'get_available_notifications',
        params: {
          'p_user_id': MySharedPreferences.userId,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      if (response == null) return [];

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      // Handle error cleanly
    }
  }

  Future<void> sendNotification({
    required String senderId,
    required String receiverId,
    required String type,
    String? entityId,
    String? title,
    String? body,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': receiverId,
        'sender_id': senderId,
        'type': type,
        'entity_id': entityId,
        'title': title,
        'body': body,
      });
    } catch (e) {
      print('Error sending persistent notification: $e');
      // rethrow; // Optional: rethrow if you want the caller to know
    }
  }
}
