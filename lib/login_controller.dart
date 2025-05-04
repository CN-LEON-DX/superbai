import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginController with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await _supabase.rpc(
        'check_login',
        params: {
          'p_gmail': email,
          'p_password': password,
        },
      );
      
      if (response['success'] == true) {
        await _secureStorage.write(key: 'user_id', value: response['user_id']);
        await _secureStorage.write(key: 'email', value: email);
        final profileData = jsonEncode(response['profile']);
        await _secureStorage.write(key: 'user_profile', value: profileData);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error during login: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  
  
  Future<bool> requestPasswordReset(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await _supabase.rpc(
        'request_password_reset',
        params: {
          'p_gmail': email,
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = 'Error requesting password reset: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userId = await _secureStorage.read(key: 'user_id');
    return userId != null;
  }
  
  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _supabase.auth.signOut();
      await _secureStorage.deleteAll();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error during logout: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
} 