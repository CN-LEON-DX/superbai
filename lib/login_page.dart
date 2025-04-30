import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';
import 'forgot_password.dart';
import 'main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() {
    print('Creating LoginPage state');
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  
  late final SupabaseClient _supabase;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    print('LoginPage initState');
    _supabase = Supabase.instance.client;
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _supabase.rpc(
        'check_login',
        params: {
          'p_gmail': _emailController.text.trim(),
          'p_password': _passwordController.text,
        },
      );
      
      if (response['success'] == true) {
        await _secureStorage.write(key: 'user_id', value: response['user_id']);
        await _secureStorage.write(key: 'email', value: response['email']);
        await _secureStorage.write(key: 'token', value: response['token']);
        await _secureStorage.write(key: 'token_expires', value: response['token_expires']);

        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Đăng nhập thất bại';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Login error: $e');
      setState(() {
        _errorMessage = 'Có lỗi xảy ra khi đăng nhập';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _checkCurrentUser() async {
    final userId = await _secureStorage.read(key: 'user_id');
    if (userId != null && mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

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
              child: Form(
                key: _formKey,
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

                    // Error Message (if any)
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    if (_errorMessage != null) const SizedBox(height: 20.0),

                    // Email/Username Label
                    Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Email/Username Input
                    TextFormField(
                      controller: _emailController,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Basic email validation
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2C2F37),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
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
                        onPressed: _isLoading ? null : _login,
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
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 30.0),

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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 