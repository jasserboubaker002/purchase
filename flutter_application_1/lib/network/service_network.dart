import 'dart:convert';
import 'package:dio/dio.dart';

import 'api.dart';
import '../models/service.dart';

class ServiceNetwork {
  APIS api = APIS();

  /// Fetch all services
  Future<List<Service>> fetchServices() async {
    print('Fetching services from API: ${APIS.baseUrl}${APIS.fetchServices}');
    try {
      Response response = await api.dio.get(
        APIS.baseUrl + APIS.fetchServices,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200) {
        print('Services fetched successfully');
        final data = response.data;
        if (data is List) {
          return data
              .map((item) => Service.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data.containsKey('results')) {
          final results = data['results'] as List?;
          return (results ?? [])
              .map((item) => Service.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch services: ${response.data}');
      }
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  /// Fetch a single service by ID
  Future<Service> getServiceById(int id) async {
    print('Fetching service with ID: $id');
    try {
      Response response = await api.dio.get(
        APIS.baseUrl + APIS.fetchServices + id.toString() + '/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Service fetched successfully');
        return Service.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch service: ${response.data}');
      }
    } catch (e) {
      print('Error fetching service: $e');
      rethrow;
    }
  }

  /// Create a new service
  Future<Service> createService(Service service) async {
    print('Creating service with data: ${service.toJson()}');
    try {
      Response response = await api.dio.post(
        APIS.baseUrl + APIS.createService,
        data: jsonEncode(service.toJson()),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Service created successfully');
        return Service.fromJson(response.data as Map<String, dynamic>);
      } else {
        print('Failed to create service: ${response.data}');
        throw Exception('Failed to create service: ${response.data}');
      }
    } catch (e) {
      print('Error creating service: $e');
      rethrow;
    }
  }

  /// Update an existing service
  Future<Service> updateService(int id, Service service) async {
    print('Updating service with ID: $id and data: ${service.toJson()}');
    try {
      Response response = await api.dio.put(
        APIS.baseUrl + APIS.editService + id.toString() + '/',
        data: jsonEncode(service.toJson()),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Service updated successfully');
        return Service.fromJson(response.data as Map<String, dynamic>);
      } else {
        print('Failed to update service: ${response.data}');
        throw Exception('Failed to update service: ${response.data}');
      }
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }

  /// Delete a service
  Future<void> deleteService(int id) async {
    print('Deleting service with ID: $id');
    try {
      Response response = await api.dio.delete(
        APIS.baseUrl + APIS.deleteService + id.toString() + '/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Service deleted successfully');
      } else {
        print('Failed to delete service: ${response.data}');
        throw Exception('Failed to delete service: ${response.data}');
      }
    } catch (e) {
      print('Error deleting service: $e');
      rethrow;
    }
  }
}
