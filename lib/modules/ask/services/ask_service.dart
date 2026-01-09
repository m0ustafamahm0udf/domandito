import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AskService {
  static Future<void> sendQuestion({
    required BuildContext context,
    required String questionText,
    required bool isAnonymous,
    required String recipientToken,
    required String recipientName,
    required String recipientUserName,
    required String recipientId,
    required String recipientImage,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    try {
      final String questionId = const Uuid().v4();
      DateTime now = await getNetworkTime() ?? DateTime.now();

      final question = QuestionModel(
        id: questionId,
        createdAt: now.toUtc(),
        title: questionText.trim(),
        sender: Sender(
          token: MySharedPreferences.deviceToken,
          userName: MySharedPreferences.userUserName,
          id: MySharedPreferences.userId,
          name: MySharedPreferences.userName,
          image: MySharedPreferences.image,
        ),
        isDeleted: false,
        images: [],
        isAnonymous: isAnonymous,
        likesCount: 0,
        commentCount: 0,
        receiver: Receiver(
          token: recipientToken,
          name: recipientName,
          userName: recipientUserName,
          id: recipientId,
          image: recipientImage,
        ),
      );

      var data = question.toJson();
      data['id'] = questionId;

      await Supabase.instance.client.from('questions').insert(data);

      if (context.mounted) {
        AppConstance().showSuccesToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'Question sent successfully'
              : 'تم إرسال السؤال بنجاح',
        );
      }

      try {
        await SendMessageNotificationWithHTTPv1().send2(
          type: AppConstance.question,
          urll: '',
          toToken: recipientToken,
          message: AppConstance.questioned,
          title: isAnonymous
              ? (!context.isCurrentLanguageAr() ? 'Anonymous' : 'مجهول')
              : MySharedPreferences.userName,
          id: questionId,
        );
      } catch (e) {
        // Notification error ignored as per original logic
      }

      onSuccess();
    } catch (e) {
      if (context.mounted) {
        AppConstance().showErrorToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'Something went wrong'
              : 'حدث خطأ أثناء الإرسال',
        );
      }
      onError();
    }
  }
}
