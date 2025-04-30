import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'forgot_password.dart';
import 'home_page.dart';
import 'utils/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    debug: false, // Set to true for development
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1F222A),
              const Color(0xFF121418),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34373F),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      size: 50.0,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // App Title
                  const Text(
                    'AI Assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // Email/Username Label
                  Text(
                    'Email or Username',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Email/Username Input
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF2C2F37),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Password Label
                  Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Password Input
                  TextField(
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF2C2F37),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to ForgotPasswordPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        alignment: Alignment.centerRight,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  // Login Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Simulate successful login and navigate to home page
                        print('Login Tapped');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 50.0),

                  // Encryption Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Colors.grey[600],
                        size: 16.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Protected by end-to-end encryption',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
