import 'package:flutter/material.dart';
import '../network/service_network.dart';
import '../models/service.dart';

class ServiceController extends ChangeNotifier {
  final ServiceNetwork _network = ServiceNetwork();

  List<Service> services = [];
  bool isLoading = false;
  String? errorMessage;

  /// Fetch all services from the API
  Future<List<Service>> fetchServices() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _network.fetchServices();
      services = List<Service>.from(data);
      isLoading = false;
      notifyListeners();
      return services;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to fetch services: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get a single service by ID
  Future<Service> getServiceById(int id) async {
    try {
      return await _network.getServiceById(id);
    } catch (e) {
      errorMessage = 'Failed to fetch service: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Create a new service
  Future<Service> createService({
    required String name,
    String? description,
  }) async {
    try {
      final service = Service(
        name: name,
        description: description,
      );
      final response = await _network.createService(service);
      services.add(response);
      notifyListeners();
      return response;
    } catch (e) {
      errorMessage = 'Failed to create service: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing service
  Future<Service> updateService({
    required int id,
    required String name,
    String? description,
  }) async {
    try {
      final service = Service(
        id: id,
        name: name,
        description: description,
      );
      final response = await _network.updateService(id, service);
      final index = services.indexWhere((s) => s.id == id);
      if (index >= 0) {
        services[index] = response;
      }
      notifyListeners();
      return response;
    } catch (e) {
      errorMessage = 'Failed to update service: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a service
  Future<void> deleteService(int id) async {
    try {
      await _network.deleteService(id);
      services.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete service: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Clear services list
  void clearServices() {
    services.clear();
    errorMessage = null;
    notifyListeners();
  }
}
