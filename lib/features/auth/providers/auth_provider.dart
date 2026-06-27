import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  // Init — check if user is already logged in
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    final userJson = prefs.getString(AppConstants.userKey);
    if (_token != null && userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Save token and user to storage
  Future<void> _saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    _token = token;
    _user = user;
  }

  // REGISTER
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiClient.post(
        AppConstants.register,
        {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final user = UserModel.fromJson(data['user']);
        await _saveSession(data['token'], user);
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Connection error. Please check your network.');
      _setLoading(false);
      return false;
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiClient.post(
        AppConstants.login,
        {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);
        await _saveSession(data['token'], user);
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Connection error. Please check your network.');
      _setLoading(false);
      return false;
    }
  }

  // FORGOT PASSWORD
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiClient.post(
        AppConstants.forgotPassword,
        {'email': email},
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Request failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Connection error. Please check your network.');
      _setLoading(false);
      return false;
    }
  }

  // RESET PASSWORD
  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiClient.post(
        AppConstants.resetPassword,
        {
          'token': token,
          'password': password,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Reset failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Connection error. Please check your network.');
      _setLoading(false);
      return false;
    }
  }

  // UPDATE PROFILE
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiClient.put(
        AppConstants.updateProfile,
        data,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _user = UserModel.fromJson(responseData['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.userKey,
          jsonEncode(_user!.toJson()),
        );
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(responseData['message'] ?? 'Update failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Connection error. Please check your network.');
      _setLoading(false);
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _token = null;
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}