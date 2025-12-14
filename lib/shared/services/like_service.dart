import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/services/notifications/send_message_notification.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/shared/models/like_model.dart';
import 'package:flutter/material.dart';

class LikeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String likesCollection = "question_likes";
  static final String questionsCollection = "questions";

  // لمنع الضغط السريع
  static final Map<String, bool> _isProcessing = {};

  /// Toggle like مع transaction + debounce
  static Future<bool> toggleLike({
    required String questionId,
    required LikeUser user,
    required BuildContext context,
  }) async {
    // لو فيه عملية شغالة على السؤال دلوقتي
    if (_isProcessing[questionId] == true) return false;

    _isProcessing[questionId] = true;

    bool result = false;

    try {
      result = await _firestore.runTransaction<bool>((transaction) async {
        final questionRef = _firestore
            .collection(questionsCollection)
            .doc(questionId);
        final likesRef = _firestore.collection(likesCollection);

        // جلب اللايك الحالي
        final likeQuery = await likesRef
            .where("questionId", isEqualTo: questionId)
            .where("user.id", isEqualTo: user.id)
            .limit(1)
            .get();

        final questionSnap = await transaction.get(questionRef);
        if (!questionSnap.exists) throw Exception("Question not found");

        int likesCount = questionSnap.get('likesCount') ?? 0;

        if (likeQuery.docs.isNotEmpty) {
          // موجود بالفعل → حذف اللايك
          transaction.delete(likeQuery.docs.first.reference);
          transaction.update(questionRef, {"likesCount": likesCount - 1});
          return false; // دلوقتي مش لایک
        } else {
          // مش موجود → إضافة now
          DateTime now = await getNetworkTime() ?? DateTime.now();

          final newLikeRef = likesRef.doc();
          final like = LikeModel(
            id: newLikeRef.id,
            questionId: questionId,
            createdAt: now,
            user: user,
          );
          transaction.set(newLikeRef, like.toJson());
          transaction.update(questionRef, {"likesCount": likesCount + 1});
          await SendMessageNotificationWithHTTPv1().send2(
            type: AppConstance.like,
            urll: '',
            toToken: user.token,
            message: AppConstance.liked,
            title: 'Domandito',
            id: questionId,
          );
          return true; // دلوقتي لایک
        }
      });
    } catch (e) {
      debugPrint("Error toggling like: $e");
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? "Something went wrong, try again"
            : "حدث خطأ، حاول مرة أخرى",
      );
    } finally {
      _isProcessing[questionId] = false;
    }

    return result;
  }

  /// تحقق إذا المستخدم عمل لايك بالفعل
  static Future<bool> isLiked({
    required String questionId,
    required String userId,
  }) async {
    final snap = await _firestore
        .collection(likesCollection)
        .where("questionId", isEqualTo: questionId)
        .where("user.id", isEqualTo: userId)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }
}
