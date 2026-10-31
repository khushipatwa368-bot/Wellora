import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Live Render Backend Base URL
  static const String baseUrl = "https://wellora-backend-wnzo.onrender.com/api";

  // =====================================================
  // AUTHENTICATION APIs
  // =====================================================

  /// User Register API
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error registering user: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// User Login API
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error logging in: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // =====================================================
  // HEALTH & WELLNESS APIs
  // =====================================================

  /// Health Tips Fetch
  Future<List<String>> getHealthTips() async {
    final url = Uri.parse('$baseUrl/health-tips');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['tips'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching health tips: $e');
      return [];
    }
  }

  /// Save Sleep Log
  Future<Map<String, dynamic>> saveSleepLog({
    required int userId,
    required String quality,
    int routineCompleted = 0,
    String? ambientSound,
  }) async {
    final url = Uri.parse('$baseUrl/sleep');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'quality': quality,
          'routine_completed': routineCompleted,
          'ambient_sound': ambientSound,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error saving sleep log: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Save Activity Log
  Future<Map<String, dynamic>> saveActivityLog({
    required int userId,
    required String activityName,
    int durationMinutes = 0,
    int studyBreak = 0,
  }) async {
    final url = Uri.parse('$baseUrl/activity');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'activity_name': activityName,
          'duration_minutes': durationMinutes,
          'study_break': studyBreak,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error saving activity: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get User Activities
  Future<List<dynamic>> getUserActivities(int userId) async {
    final url = Uri.parse('$baseUrl/activity/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['activities'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      return [];
    }
  }

  // =====================================================
  // NUTRITION & HYDRATION APIs
  // =====================================================

  /// Get User Nutrition Data
  Future<Map<String, dynamic>> getNutritionData(int userId) async {
    final url = Uri.parse('$baseUrl/nutrition/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false};
    } catch (e) {
      debugPrint('Error fetching nutrition data: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update Hydration Data
  Future<Map<String, dynamic>> updateHydration({
    required int userId,
    required int waterGlasses,
  }) async {
    final url = Uri.parse('$baseUrl/hydration');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'water_glasses': waterGlasses,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error updating hydration: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}