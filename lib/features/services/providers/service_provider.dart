import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/models/user_model.dart';
import '../models/service_model.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<UserModel> _technicians = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  List<UserModel> get technicians => _technicians;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch all services
  Future<void> fetchServices() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiClient.get(
        AppConstants.services,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _services = data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        _error = 'Failed to load services';
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all technicians
  Future<void> fetchTechnicians() async {
    try {
      final response = await ApiClient.get(
        AppConstants.technicians,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _technicians = data.map((json) => UserModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Silent fail — technicians list is supplementary
    }
  }

  // Fetch both at once (used on Home screen load)
  Future<void> fetchHomeData() async {
    _setLoading(true);
    _error = null;

    try {
      final results = await Future.wait([
        ApiClient.get(AppConstants.services, requiresAuth: false),
        ApiClient.get(AppConstants.technicians, requiresAuth: false),
      ]);

      final servicesResponse = results[0];
      final techniciansResponse = results[1];

      if (servicesResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(servicesResponse.body);
        _services = data.map((json) => ServiceModel.fromJson(json)).toList();
      }

      if (techniciansResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(techniciansResponse.body);
        _technicians = data.map((json) => UserModel.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
    } finally {
      _setLoading(false);
    }
  }

  // Get services filtered by category
  List<ServiceModel> servicesByCategory(String category) {
    if (category == 'All') return _services;
    return _services
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}