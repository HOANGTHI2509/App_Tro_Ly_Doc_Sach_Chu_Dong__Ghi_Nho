import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient('https://kvechqvsflmmxruikrtt.supabase.co', 'sb_publishable_Bn9x0JxeSONUEDX_ItvyJQ__9hwuUMT');
  try {
    final friends = await client.from('friendships').select();
    print('Friendships: $friends');

    final activities = await client.from('activities').select();
    print('Activities: $activities');
  } catch (e) {
    print('Error: $e');
  }
}
