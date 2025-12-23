import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> togglePin(String questionId, bool newStatus) async {
    try {
      await _supabase
          .from('questions')
          .update({'is_pinned': newStatus})
          .eq('id', questionId);
    } catch (e) {
      throw Exception('Failed to toggle pin status: $e');
    }
  }
}
