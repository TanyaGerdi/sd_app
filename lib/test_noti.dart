import 'package:supabase/supabase.dart';
void main() async {
  final supabase = SupabaseClient('https://ikbiagrswdbbzxwxcmkn.supabase.co', 'sb_publishable_0z4SwUSLgZTSVBsjh9mOeg_3f32RHEj');
  final res = await supabase.from('notifications').select().limit(1);
  print('Result: $res');
}
