import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient('https://kvechqvsflmmxruikrtt.supabase.co', 'sb_publishable_Bn9x0JxeSONUEDX_ItvyJQ__9hwuUMT');
  try {
    final res = await client.from('activities').select();
    print('Total activities in DB: ${res.length}');
    print(res);
  } catch (e) {
    print('Error: $e');
  }
}
