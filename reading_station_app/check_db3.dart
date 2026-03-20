import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient('https://kvechqvsflmmxruikrtt.supabase.co', 'sb_publishable_Bn9x0JxeSONUEDX_ItvyJQ__9hwuUMT');
  try {
    // We can't easily sign in without password, but maybe we can just query users table.
    final res = await client.auth.signInWithPassword(email: 'nhattan2@gmail.com', password: 'password123'); // Just a guess.
    
    await client.from('activities').insert({
        'user_id': res.user!.id,
        'type': 'created_note',
        'book_title': 'Test book',
        'note_content': 'Test note content',
    });
    print('Inserted successfully');
  } catch (e) {
    print('Error: $e');
  }
}
