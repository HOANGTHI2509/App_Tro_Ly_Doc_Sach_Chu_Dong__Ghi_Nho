import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://kvechqvsflmmxruikrtt.supabase.co',
    'sb_publishable_Bn9x0JxeSONUEDX_ItvyJQ__9hwuUMT',
  );

  try {
    // Just fetch all users to see if there are any
    final users = await supabase.from('users').select().limit(10);
    print('Users count: ${users.length}');
    for (var u in users) {
      print('${u['id']} - ${u['name']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
