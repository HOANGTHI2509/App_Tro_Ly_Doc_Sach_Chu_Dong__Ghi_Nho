import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/constants/supabase_constants.dart';

void main() async {
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
  
  final supabase = Supabase.instance.client;

  // For Supabase Dart SDK, to execute admin raw SQL, we use RPC.
  // But wait! Is there an RPC for raw SQL?
  // If not, we cannot create RLS policies through Flutter.
  
}
