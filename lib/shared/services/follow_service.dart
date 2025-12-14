import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:domandito/shared/models/follow_model.dart';
import 'package:domandito/core/constants/app_constants.dart';

class FollowService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String followCollection = "follows";
  static const String usersCollection = "users";

  static final Map<String, bool> _isProcessing = {};

  /// ---------------------------------------------------------------------------
  /// 🔁 Toggle Follow (Follow / Unfollow)
  /// ---------------------------------------------------------------------------
  static Future<bool> toggleFollow({
    required FollowUser me, // أنا
    required FollowUser targetUser, // الشخص اللي هتابعه
    required BuildContext context,
  }) async {
    if (_isProcessing[targetUser.id] == true) return false;
    _isProcessing[targetUser.id] = true;

    bool isNowFollowing = false;

    try {
      isNowFollowing = await _firestore.runTransaction<bool>((
        transaction,
      ) async {
        final followsRef = _firestore.collection(followCollection);

        /// هل أنا بالفعل أتابع targetUser ؟
        final followQuery = await followsRef
            .where("me.id", isEqualTo: me.id)
            .where("targetUser.id", isEqualTo: targetUser.id)
            .limit(1)
            .get();

        final targetRef = _firestore
            .collection(usersCollection)
            .doc(targetUser.id);

        final meRef = _firestore.collection(usersCollection).doc(me.id);

        final targetSnap = await transaction.get(targetRef);
        final meSnap = await transaction.get(meRef);

        if (!targetSnap.exists || !meSnap.exists) {
          throw Exception("User not found");
        }

        int targetFollowers = targetSnap.get("followersCount") ?? 0;
        int myFollowing = meSnap.get("followingCount") ?? 0;

        if (followQuery.docs.isNotEmpty) {
          // -------------------------------------------------------------------
          // ❌ Unfollow
          // -------------------------------------------------------------------
          transaction.delete(followQuery.docs.first.reference);

          transaction.update(targetRef, {
            "followersCount": targetFollowers - 1,
          });

          transaction.update(meRef, {"followingCount": myFollowing - 1});

          return false;
        } else {
          // -------------------------------------------------------------------
          // ❤️ Follow
          // -------------------------------------------------------------------
          final newDoc = followsRef.doc();
    DateTime now = await getNetworkTime() ?? DateTime.now();

          final follow = FollowModel(
            id: newDoc.id,
            createdAt: now,
            me: me,
            targetUser: targetUser,
          );

          transaction.set(newDoc, follow.toJson());

          transaction.update(targetRef, {
            "followersCount": targetFollowers + 1,
          });

          transaction.update(meRef, {"followingCount": myFollowing + 1});
       
          return true;
        }
      });
    } catch (e) {
      debugPrint("Follow error: $e");
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? "Something went wrong, try again"
            : "حدث خطأ، حاول مرة أخرى",
      );
    } finally {
      _isProcessing[targetUser.id] = false;
    }

    return isNowFollowing;
  }

  /// ---------------------------------------------------------------------------
  /// ❓ Check if I follow this user
  /// ---------------------------------------------------------------------------
  static Future<bool> isFollowing({
    required String myId,
    required String targetUserId,
  }) async {
    final snap = await _firestore
        .collection(followCollection)
        .where("me.id", isEqualTo: myId)
        .where("targetUser.id", isEqualTo: targetUserId)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }
}
