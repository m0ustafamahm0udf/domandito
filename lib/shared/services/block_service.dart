import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/shared/models/bloced_user.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_constants.dart';

class BlockService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String blockCollection = "blocked_users";
  static const String usersCollection = "users";

  static final Map<String, bool> _isProcessing = {};

  /// ---------------------------------------------------------------------------
  /// 🚫 Toggle Block (Block / Unblock)
  /// ---------------------------------------------------------------------------
  static Future<bool> toggleBlock({
    required BlockUser blocker, // أنا
    required BlockUser blocked, // الشخص اللي هحظره
    required BuildContext context,
  }) async {
    if (_isProcessing[blocked.id] == true) return false;
    _isProcessing[blocked.id] = true;

    bool isNowBlocked = false;

    try {
      isNowBlocked = await _firestore.runTransaction<bool>((transaction) async {
        final blocksRef = _firestore.collection(blockCollection);

        /// هل أنا بالفعل عملت Block لهذا المستخدم؟
        final blockQuery = await blocksRef
            .where("blocker.id", isEqualTo: blocker.id)
            .where("blocked.id", isEqualTo: blocked.id)
            .limit(1)
            .get();

        final blockerRef = _firestore.collection(usersCollection).doc(blocker.id);
        final blockedRef = _firestore.collection(usersCollection).doc(blocked.id);

        final blockerSnap = await transaction.get(blockerRef);
        final blockedSnap = await transaction.get(blockedRef);

        if (!blockerSnap.exists || !blockedSnap.exists) {
          throw Exception("User not found");
        }

        if (blockQuery.docs.isNotEmpty) {
          // -------------------------------------------------------------------
          // ❌ Unblock
          // -------------------------------------------------------------------
          transaction.delete(blockQuery.docs.first.reference);
          return false;
        } else {
          // -------------------------------------------------------------------
          // 🚫 Block
          // -------------------------------------------------------------------
          final newDoc = blocksRef.doc();
          DateTime now = await getNetworkTime() ?? DateTime.now();

          final block = BlockModel(
            id: newDoc.id,
            createdAt: now,
            blocker: blocker,
            blocked: blocked,
          );

          transaction.set(newDoc, block.toJson());

          return true;
        }
      });
    } catch (e) {
      debugPrint("Block error: $e");
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? "Something went wrong, try again"
            : "حدث خطأ، حاول مرة أخرى",
      );
    } finally {
      _isProcessing[blocked.id] = false;
    }

    return isNowBlocked;
  }

  /// ---------------------------------------------------------------------------
  /// ❓ Check if I blocked this user
  /// ---------------------------------------------------------------------------
  static Future<bool> isBlocked({
    required String myId,
    required String targetUserId,
  }) async {
    final snap = await _firestore
        .collection(blockCollection)
        .where("blocker.id", isEqualTo: myId)
        .where("blocked.id", isEqualTo: targetUserId)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  /// ---------------------------------------------------------------------------
  /// 📋 Get all blocked user IDs (for filtering)
  /// ---------------------------------------------------------------------------
  static Future<List<String>> getBlockedUserIds(String myId) async {
    final snap = await _firestore
        .collection(blockCollection)
        .where("blocker.id", isEqualTo: myId)
        .get();

    return snap.docs.map((e) => e['blocked']['id'] as String).toList();
  }
}
