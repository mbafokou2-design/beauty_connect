import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/service_model.dart';

class MyServicesProvider extends ChangeNotifier {
  List<ServiceModel> _myServices = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get myServices => _myServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchMyServices() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiClient.get(AppConstants.myServices);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _myServices = data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        _error = 'Failed to load your services';
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
    } finally {
      _setLoading(false);
    }
  }

  // Toggle isAvailable instantly (optimistic update)
  Future<bool> toggleAvailability(ServiceModel service) async {
    final index = _myServices.indexWhere((s) => s.id == service.id);
    if (index == -1) return false;

    final newValue = !service.isAvailable;

    // Optimistic UI update
    _myServices[index] = ServiceModel(
      id: service.id,
      name: service.name,
      description: service.description,
      price: service.price,
      durationMinutes: service.durationMinutes,
      category: service.category,
      imageUrl: service.imageUrl,
      isAvailable: newValue,
      technicianId: service.technicianId,
      technician: service.technician,
    );
    notifyListeners();

    try {
      final response = await ApiClient.put(
        '${AppConstants.services}/${service.id}',
        {'isAvailable': newValue},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Revert on failure
        _myServices[index] = service;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _myServices[index] = service;
      notifyListeners();
      return false;
    }
  }

  // Create a new service (with optional image)
  Future<bool> createService({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required String category,
    String? imagePath,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final fields = {
        'name': name,
        'description': description,
        'price': price.toString(),
        'durationMinutes': durationMinutes.toString(),
        'category': category,
      };

      final response = imagePath != null
          ? await ApiClient.postWithImage(
              AppConstants.services,
              fields,
              imagePath,
              'image',
            )
          : await ApiClient.post(AppConstants.services, fields, requiresAuth: true);

      if (response.statusCode == 201) {
        await fetchMyServices();
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to create service';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _setLoading(false);
      return false;
    }
  }

  // Delete a service
  Future<bool> deleteService(int serviceId) async {
    try {
      final response = await ApiClient.delete('${AppConstants.services}/$serviceId');

      if (response.statusCode == 200) {
        _myServices.removeWhere((s) => s.id == serviceId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}