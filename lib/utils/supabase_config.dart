import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
} 