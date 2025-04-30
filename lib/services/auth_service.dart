import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  final secureStorage = const FlutterSecureStorage();
  final supabase = Supabase.instance.client;
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL', // Replace with your Supabase URL
      anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
    );
  }
  
  String _generateSalt() {
    final random = Random.secure();
    final List<int> saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
  
  String _hashPassword(String password, String salt) {
    final key = utf8.encode(password);
    final saltBytes = base64Decode(salt);  
    final hmacSha256 = Hmac(sha256, saltBytes);
    final digest = hmacSha256.convert(key);
    return base64Encode(digest.bytes);  
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await supabase.rpc(
        'check_login',
        params: {
          'p_gmail': email,
          'p_password': password,
        },
      );
      
      if (response['success'] == true) {
        await secureStorage.write(key: 'user_id', value: response['user_id']);
        await secureStorage.write(key: 'email', value: email);
        
        final profileData = jsonEncode(response['profile']);
        await secureStorage.write(key: 'user_profile', value: profileData);
        
        return {
          'success': true,
          'message': 'Login successful',
          'user': response,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Login failed',
          'code': response['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during login: ${e.toString()}',
        'code': 'UNKNOWN_ERROR',
      };
    }
  }
  
  
  
  String _generateRandomPassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
  
  Future<Map<String, dynamic>> register(String email, String password, {String? name}) async {
    try {
      final existingUser = await supabase
          .from('superbai_account')
          .select()
          .eq('gmail', email)
          .maybeSingle();
      
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Email already registered',
          'code': 'EMAIL_EXISTS',
        };
      }
      
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      final response = await supabase.rpc(
        'register_user',
        params: {
          
          'p_gmail': email,
          'p_password': password,
          'p_name': name,
        },
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'message': 'Registration successful',
          'user_id': response['user_id'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Registration failed',
          'code': response['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during registration: ${e.toString()}',
        'code': 'UNKNOWN_ERROR',
      };
    }
  }
  
  // Request password reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await supabase.rpc(
        'request_password_reset',
        params: {
          'p_gmail': email,
        },
      );
      
      return {
        'success': response['success'] ?? false,
        'message': response['message'] ?? 'Password reset request sent',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error requesting password reset: ${e.toString()}',
      };
    }
  }
  
  // Reset password with token
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await supabase.rpc(
        'reset_password',
        params: {
          'p_token': token,
          'p_new_password': newPassword,
        },
      );
      
      return {
        'success': response['success'] ?? false,
        'message': response['message'] ?? 'Password reset failed',
        'code': response['code'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error resetting password: ${e.toString()}',
        'code': 'UNKNOWN_ERROR',
      };
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userId = await secureStorage.read(key: 'user_id');
    return userId != null;
  }
  
  // Get current user ID
  Future<String?> getUserId() async {
    return await secureStorage.read(key: 'user_id');
  }
  
  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final profileData = await secureStorage.read(key: 'user_profile');
    if (profileData != null) {
      return jsonDecode(profileData);
    }
    return null;
  }
  
  // Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
    await secureStorage.deleteAll();
  }
} 