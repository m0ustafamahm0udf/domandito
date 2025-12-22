import 'dart:developer';

import 'package:domandito/core/utils/extentions.dart';

import 'package:domandito/shared/models/bloced_user.dart';
import 'package:domandito/shared/services/follow_service.dart';
import 'package:flutter/material.dart';
import 'package:domandito/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlockService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const String blockTable = "blocks";
  // static const String usersCollection = "users"; // Unused in Supabase implementation

  static final Map<String, bool> _isProcessing = {};

  /// ---------------------------------------------------------------------------
  /// 🚫 Toggle Block (Block / Unblock)
  /// ---------------------------------------------------------------------------
  static Future<bool> toggleBlock({
    required BlockUser blocker,
    required BlockUser blocked,
    required BuildContext context,
  }) async {
    if (_isProcessing[blocked.id] == true) return false;
    _isProcessing[blocked.id] = true;

    bool isNowBlocked = false;

    try {
      // 1. Check if block already exists - Limit 1 to avoid multiple row errors
      final existingBlock = await _supabase
          .from(blockTable)
          .select()
          .match({'blocker_id': blocker.id, 'blocked_id': blocked.id})
          .limit(1)
          .maybeSingle();

      if (existingBlock != null) {
        // -------------------------------------------------------------------
        // ❌ Unblock
        // -------------------------------------------------------------------
        debugPrint("[BlockService] Unblocking user ${blocked.id}");

        final blockId = existingBlock['id'];
        if (blockId != null) {
          await _supabase.from(blockTable).delete().eq('id', blockId);
        } else {
          await _supabase.from(blockTable).delete().match({
            'blocker_id': blocker.id,
            'blocked_id': blocked.id,
          });
        }

        isNowBlocked = false;
      } else {
        // -------------------------------------------------------------------
        // 🚫 Block (and Unfollow First)
        // -------------------------------------------------------------------
        debugPrint(
          "[BlockService] Blocking user ${blocked.id} - Step 1: Force Unfollow",
        );

        // Step 1: Explicitly Unfollow (Wait for it)
        await FollowService.forceUnfollow(
          followerId: blocker.id,
          followingId: blocked.id,
        ).then((_) async {
          debugPrint(
            "[BlockService] Blocking user ${blocked.id} - Step 2: Insert Block",
          );

          // Step 2: Insert Block
          await _supabase.from(blockTable).insert({
            'blocker_id': blocker.id,
            'blocked_id': blocked.id,
          });

          isNowBlocked = true;
        });
      }
    } catch (e) {
      debugPrint("Block Service Error: $e");

      if (context.mounted) {
        log("Block Service Error: $e");
        AppConstance().showInfoToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? "Operation failed: $e"
              : "فشلت العملية",
        );
      }
      isNowBlocked = false; // Assume fail
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
    try {
      final snap = await _supabase.from(blockTable).select().match({
        'blocker_id': myId,
        'blocked_id': targetUserId,
      }).maybeSingle();

      return snap != null;
    } catch (e) {
      debugPrint("Check Block error: $e");
      return false;
    }
  }

  /// ---------------------------------------------------------------------------
  /// 📋 Get all blocked user IDs (for filtering)
  /// ---------------------------------------------------------------------------
  static Future<List<String>> getBlockedUserIds(String myId) async {
    try {
      final snap = await _supabase
          .from(blockTable)
          .select('blocked_id')
          .eq('blocker_id', myId);

      final data = snap as List<dynamic>;
      return data.map((e) => e['blocked_id'] as String).toList();
    } catch (e) {
      debugPrint("Get Blocked Users error: $e");
      return [];
    }
  }

  /// ---------------------------------------------------------------------------
  /// 📋 Get list of users who blocked ME (to hide them from search)
  /// ---------------------------------------------------------------------------
  static Future<List<String>> getWhoBlockedMe(String myId) async {
    try {
      final snap = await _supabase
          .from(blockTable)
          .select('blocker_id')
          .eq('blocked_id', myId);

      final data = snap as List<dynamic>;
      return data.map((e) => e['blocker_id'] as String).toList();
    } catch (e) {
      debugPrint("Get Who Blocked Me error: $e");
      return [];
    }
  }

  /// ---------------------------------------------------------------------------
  /// 🚫 Check if I am blocked by this user
  /// ---------------------------------------------------------------------------
  static Future<bool> amIBlocked({
    required String myId,
    required String targetUserId,
  }) async {
    debugPrint("checking amIBlocked: myId=$myId, target=$targetUserId");
    try {
      final snap = await _supabase.from(blockTable).select().match({
        'blocker_id': targetUserId,
        'blocked_id': myId,
      }).maybeSingle();

      debugPrint("amIBlocked response: $snap");
      return snap != null;
    } catch (e) {
      debugPrint("Check Am I Blocked error: $e");
      return false;
    }
  }
}
