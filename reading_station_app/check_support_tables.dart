import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/constants/supabase_constants.dart';

void main() async {
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
  try {
    // Attempt to query the tables
    final reqs = await Supabase.instance.client.from('support_requests').select().limit(1);
    print('support_requests exists: $reqs');
    
    final msgs = await Supabase.instance.client.from('support_messages').select().limit(1);
    print('support_messages exists: $msgs');
  } catch (e) {
    print('Error querying tables: $e');
  }
}
