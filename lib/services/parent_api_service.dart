import 'api_service.dart';

class ParentApiService {
  /// Fetch parent profile and list of linked children
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get('/parent/me');
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to load parent profile');
  }

  /// Fetch child attendance
  static Future<Map<String, dynamic>> getChildAttendance(
    String studentId, {
    int? month,
    int? year,
  }) async {
    String endpoint = '/parent/children/$studentId/attendance';
    final queryParams = <String>[];
    if (month != null) queryParams.add('month=$month');
    if (year != null) queryParams.add('year=$year');
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await ApiService.get(endpoint);
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to load attendance');
  }

  /// Fetch child fee breakdown and payment transactions
  static Future<Map<String, dynamic>> getChildFees(String studentId) async {
    final response = await ApiService.get('/parent/children/$studentId/fees');
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to load fees');
  }

  /// Fetch notices / broadcasts for student
  static Future<List<dynamic>> getChildNotices(String studentId) async {
    final response = await ApiService.get('/parent/children/$studentId/notices');
    if (response is List) {
      return response;
    }
    throw Exception('Failed to load notices');
  }

  /// Fetch class teacher and subject teachers
  static Future<Map<String, dynamic>> getChildTeachers(String studentId) async {
    final response = await ApiService.get('/parent/children/$studentId/teachers');
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to load teachers');
  }

  /// Get or create chat thread with class teacher
  static Future<Map<String, dynamic>> getChatThread(String studentId) async {
    final response = await ApiService.get('/parent/children/$studentId/chat');
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to load chat thread');
  }

  /// Send message to class teacher
  static Future<Map<String, dynamic>> sendMessage(String studentId, String body) async {
    final response = await ApiService.post('/parent/children/$studentId/chat/messages', {
      'body': body,
    });
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to send message');
  }

  /// Fetch school holidays
  static Future<List<dynamic>> getHolidays() async {
    final response = await ApiService.get('/parent/holidays');
    if (response is List) {
      return response;
    }
    throw Exception('Failed to load holidays');
  }
}
