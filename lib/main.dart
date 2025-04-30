import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'forgot_password.dart';
import 'home_page.dart';
import 'utils/supabase_config.dart';
import 'login_page.dart';

void main() async {
  try {
    print('Starting app...');
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');

    print('Loading .env file');
    await dotenv.load(fileName: ".env");
    print('Loaded .env file');
    
    print('Supabase URL: ${SupabaseConfig.supabaseUrl}');
    print('Initializing Supabase...');
    
    if (SupabaseConfig.supabaseUrl.isEmpty || SupabaseConfig.supabaseAnonKey.isEmpty) {
      throw Exception('Supabase configuration is missing. Please check your .env file.');
    }

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: true,
    );
    print('Supabase initialized successfully');

    print('Running app...');
    runApp(const MyApp());
    print('App started');
  } catch (e, stackTrace) {
    print('Error in main: $e');
    print('Stack trace: $stackTrace');
    
    // Show error widget instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e', 
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    print('Building MyApp');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1F222A),
        hintColor: Colors.grey[600],
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F222A),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white70),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[400],
          )
        ),
      ),
      home: const LoginPage(),
    );
  }
}
