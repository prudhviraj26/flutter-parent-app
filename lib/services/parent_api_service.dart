import 'api_service.dart';
import '../models/models.dart';

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

  /// Fetch class updates (homework & classwork) for student
  static Future<List<dynamic>> getChildClassUpdates(String studentId) async {
    try {
      final response = await ApiService.get('/parent/children/$studentId/class-updates');
      if (response is List) {
        return response;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Mark notice / broadcast as read
  static Future<bool> markNoticeRead(String noticeId) async {
    try {
      final response = await ApiService.post('/parent/notices/$noticeId/read', {});
      return response != null;
    } catch (_) {
      return false;
    }
  }

  /// Mark all notices as read for a child
  static Future<bool> markAllNoticesRead(String studentId) async {
    try {
      final response = await ApiService.post('/parent/children/$studentId/notices/mark-all-read', {});
      return response != null;
    } catch (_) {
      return false;
    }
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

  /// Delta polling for new messages in active chat
  static Future<Map<String, dynamic>> getChatDeltaMessages(String studentId, {String? since}) async {
    final query = since != null ? '?since=${Uri.encodeComponent(since)}' : '';
    final response = await ApiService.get('/parent/children/$studentId/chat/messages$query');
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'messages': []};
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

  /// Mark chat thread as read by parent
  static Future<bool> markChatThreadRead(String studentId) async {
    try {
      await ApiService.post('/parent/children/$studentId/chat/read', {});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Soft delete message
  static Future<bool> deleteChatMessage(String studentId, String messageId) async {
    try {
      await ApiService.delete('/parent/children/$studentId/chat/messages/$messageId');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch academic years for school
  static Future<List<dynamic>> getAcademicYears() async {
    try {
      final response = await ApiService.get('/parent/academic-years');
      if (response is List) {
        return response;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch school holidays calendar
  static Future<List<dynamic>> getHolidays({String? academicYearId}) async {
    String endpoint = '/parent/holidays';
    if (academicYearId != null && academicYearId.isNotEmpty) {
      endpoint += '?academicYearId=$academicYearId';
    }
    final response = await ApiService.get(endpoint);
    if (response is List) {
      return response;
    }
    throw Exception('Failed to load holidays');
  }

  /// Fetch school & class events for student
  static Future<List<dynamic>> getChildEvents(String studentId) async {
    final response = await ApiService.get('/parent/children/$studentId/events');
    if (response is List) {
      return response;
    }
    return [];
  }

  /// Fetch medical / health records for student
  static Future<Map<String, dynamic>> getChildHealth(String studentId) async {
    final response = await ApiService.get('/parent/children/$studentId/health');
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Failed to load health records');
  }

  /// Fetch media gallery albums for student
  static Future<List<Album>> getChildGallery(String studentId) async {
    final response = await ApiService.get('/parent/children/$studentId/gallery');
    if (response is List) {
      return response.map((json) => Album.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

