import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/parent_api_service.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Language & Session
  String _language = 'en';
  bool _loggedIn = false;
  String? _mobile;

  // Selected Child Specs
  Child? _currentChild;
  List<Child> _children = [];

  // Child Avatars mapping
  final Map<String, String> _childAvatars = {};

  List<Notice> _noticesDb = [];
  final Map<String, List<Notice>> _childNoticesDb = {};
  bool _isNoticesLoading = false;
  bool get isNoticesLoading => _isNoticesLoading;
  Set<String> _readNoticeIds = {};
  Set<String> get readNoticeIds => _readNoticeIds;
  bool isNoticeRead(String id) => _readNoticeIds.contains(id);
  int get unreadNoticesCount => notices.where((n) => !isNoticeRead(n.id)).length;
  Map<String, List<ClassUpdate>> _classUpdatesDb = {};
  Map<String, List<Teacher>> _teachersDb = {};
  Map<String, Attendance> _attendanceDb = {};
  Map<String, List<Event>> _eventsDb = {};
  bool _isEventsLoading = false;
  bool get isEventsLoading => _isEventsLoading;
  final Map<String, HealthRecord> _healthRecordsDb = {};
  bool _isHealthLoading = false;
  bool get isHealthLoading => _isHealthLoading;
  HealthRecord getChildHealthRecord(String studentId) =>
      _healthRecordsDb[studentId] ?? HealthRecord.empty(studentId);
  Map<String, Fee> _feesDb = {};
  List<Album> _albumsDb = [];
  List<Holiday> _holidaysDb = [];
  List<AcademicYearItem> _academicYears = [];
  List<AcademicYearItem> get academicYears => _academicYears;
  String? _selectedAcademicYearId;
  String? get selectedAcademicYearId => _selectedAcademicYearId;
  final Map<String, List<Holiday>> _academicYearHolidaysDb = {};
  bool _isHolidaysLoading = false;
  bool get isHolidaysLoading => _isHolidaysLoading;

  List<ExamResult> _examResultsDb = [];
  Map<String, List<Book>> _booksDb = {};

  bool _mustChangePassword = false;

  // Getters
  String get language => _language;
  bool get loggedIn => _loggedIn;
  bool get mustChangePassword => _mustChangePassword;
  String? get mobile => _mobile;
  Child get currentChild {
    if (_currentChild != null) return _currentChild!;
    if (_children.isNotEmpty) return _children[0];
    return Child.empty();
  }
  List<Child> get children => _children;
  Map<String, String> get childAvatars => _childAvatars;

  String _schoolName = '';
  String get currentSchoolName => _schoolName.isNotEmpty ? _schoolName : 'Veyho School';

  String? _schoolLogoUrl;
  String? get schoolLogoUrl => _schoolLogoUrl;
  String? _schoolLogoBase64;
  String? get schoolLogoBase64 => _schoolLogoBase64;

  SchoolConfig get schoolConfig => SchoolConfig(
    name: currentSchoolName,
    nameMarathi: currentSchoolName,
    logo: _schoolLogoUrl ?? '',
  );

  final Map<String, String> veyhoBranding = {
    'companyName': 'Veyho Technologies',
    'companyNameMarathi': 'वेहो टेक्नॉलॉजीज',
    'tagline': 'Powered by Veyho',
    'taglineMarathi': 'वेहो द्वारे संचालित'
  };

  AppState() {
    _initPreferences();
  }

  // Load preferences from local storage
  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Load language preference
    _language = _prefs?.getString('veyho_app_language') ?? 'en';

    // Load cached school name & logo
    final cachedSchool = _prefs?.getString('veyho_cached_school_name');
    if (cachedSchool != null && cachedSchool.isNotEmpty) {
      _schoolName = cachedSchool;
    }
    _schoolLogoUrl = _prefs?.getString('veyho_cached_school_logo_url');
    _schoolLogoBase64 = _prefs?.getString('veyho_cached_school_logo');

    // Load cached children for instant rendering on cold start
    final cachedChildrenJson = _prefs?.getString('veyho_cached_children');
    if (cachedChildrenJson != null && cachedChildrenJson.isNotEmpty) {
      try {
        final List decoded = json.decode(cachedChildrenJson);
        _children = decoded
            .map((c) => Child.fromJson(c as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error restoring cached children: $e');
      }
    }

    // Load active child ID
    final savedChildId = _prefs?.getString('veyho_active_child_id');
    if (savedChildId != null && _children.isNotEmpty) {
      final idx = _children.indexWhere((c) => c.id == savedChildId);
      if (idx != -1) {
        _currentChild = _children[idx];
      } else {
        _currentChild = _children[0];
      }
    } else if (_children.isNotEmpty) {
      _currentChild = _children[0];
    }

    // Load login session
    final userJson = _prefs?.getString('veyho_parent_user');
    if (userJson != null) {
      try {
        final Map<String, dynamic> userData = json.decode(userJson);
        _loggedIn = userData['loggedIn'] as bool? ?? false;
        _mobile = userData['mobile'] as String?;
        _mustChangePassword = userData['mustChangePassword'] as bool? ?? false;
      } catch (e) {
        _prefs?.remove('veyho_parent_user');
      }
    }

    // Load child avatars
    for (var child in _children) {
      final avatarBase64 = _prefs?.getString('veyho_child_avatar_${child.id}');
      if (avatarBase64 != null) {
        _childAvatars[child.id] = avatarBase64;
      }
    }

    // Load read notices tracking
    await _loadReadNoticeIds();

    notifyListeners();

    if (_loggedIn) {
      fetchLiveProfile();
    }
  }

  /// Download an image once and cache it as base64 in local device storage
  Future<void> _cacheImageLocally(
    String url,
    String prefKey,
    void Function(String base64Data) onCached,
  ) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        final b64 = base64Encode(res.bodyBytes);
        await _prefs?.setString(prefKey, b64);
        onCached(b64);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error caching image locally ($prefKey): $e');
    }
  }

  bool _isLoadingLive = false;
  bool get isLoadingLive => _isLoadingLive;

  Future<void> fetchLiveProfile() async {
    if (!_loggedIn) return;
    try {
      _isLoadingLive = true;
      notifyListeners();

      final profile = await ParentApiService.getProfile();
      if (profile['schoolName'] != null && profile['schoolName'].toString().isNotEmpty) {
        _schoolName = profile['schoolName'].toString();
        await _prefs?.setString('veyho_cached_school_name', _schoolName);
      }

      if (profile['schoolLogoUrl'] != null && profile['schoolLogoUrl'].toString().isNotEmpty) {
        _schoolLogoUrl = profile['schoolLogoUrl'].toString();
        await _prefs?.setString('veyho_cached_school_logo_url', _schoolLogoUrl!);
        if (_schoolLogoBase64 == null) {
          _cacheImageLocally(_schoolLogoUrl!, 'veyho_cached_school_logo', (b64) {
            _schoolLogoBase64 = b64;
          });
        }
      }

      if (profile['children'] != null && (profile['children'] as List).isNotEmpty) {
        final List childrenList = profile['children'];
        _children = childrenList.map<Child>((c) {
          String dobFormatted = '—';
          if (c['dateOfBirth'] != null) {
            final s = c['dateOfBirth'].toString();
            if (s.contains('-') && s.length >= 10) {
              final parts = s.substring(0, 10).split('-');
              if (parts.length == 3) {
                dobFormatted = '${parts[2]}-${parts[1]}-${parts[0]}';
              }
            } else {
              dobFormatted = s;
            }
          }

          if (c['healthRecord'] != null && c['healthRecord'] is Map<String, dynamic>) {
            _healthRecordsDb[c['id'].toString()] =
                HealthRecord.fromJson(c['healthRecord'] as Map<String, dynamic>);
          }

          return Child(
            id: c['id'].toString(),
            name: c['fullName'] ?? '${c['firstName']} ${c['lastName']}',
            grade: '${c['className']} ${c['sectionName']}'.trim(),
            enrollmentNo: c['grNumber']?.toString() ?? '1001',
            dob: dobFormatted,
            gender: c['gender'] ?? 'Male',
            apaarId: c['apaarId']?.toString() ?? '—',
            penNo: c['penNumber']?.toString() ?? '—',
            studentId: c['id'].toString(),
            photoUrl: c['photoUrl'] as String?,
            rollNumber: c['rollNumber'] as String?,
          );
        }).toList();

        // Save real children to cache for instant rendering next time
        await _prefs?.setString(
          'veyho_cached_children',
          json.encode(_children.map((c) => c.toJson()).toList()),
        );

        // Cache child photos locally
        for (var child in _children) {
          if (child.photoUrl != null && child.photoUrl!.isNotEmpty && !_childAvatars.containsKey(child.id)) {
            _cacheImageLocally(child.photoUrl!, 'veyho_child_avatar_${child.id}', (b64) {
              _childAvatars[child.id] = b64;
            });
          }
        }

        final savedChildId = _prefs?.getString('veyho_active_child_id');
        final idx = _children.indexWhere((c) => c.id == savedChildId);
        _currentChild = idx != -1 ? _children[idx] : _children[0];
        await _prefs?.setString('veyho_active_child_id', currentChild.id);

        await fetchLiveChildData(currentChild.id);
      }
    } catch (e) {
      debugPrint('Live profile fetch note: $e');
      final errStr = e.toString().toLowerCase();
      // If token refresh failed and session is terminated/revoked on server
      if (errStr.contains('unauthorized') || errStr.contains('session expired') || errStr.contains('revoked')) {
        await logout();
      }
    } finally {
      _isLoadingLive = false;
      notifyListeners();
    }
  }

  Future<void> fetchLiveChildData(String studentId) async {
    if (studentId.isEmpty) return;
    try {
      final results = await Future.wait([
        ParentApiService.getChildAttendance(studentId),
        ParentApiService.getChildFees(studentId),
        ParentApiService.getChildNotices(studentId),
        ParentApiService.getChildTeachers(studentId),
        ParentApiService.getChildEvents(studentId),
        ParentApiService.getChildHealth(studentId).catchError((_) => <String, dynamic>{}),
        ParentApiService.getChildClassUpdates(studentId).catchError((_) => <dynamic>[]),
      ]);

      // 1. Attendance
      try {
        final attData = results[0] as Map<String, dynamic>;
        if (attData['summary'] != null) {
          _attendanceDb[studentId] = _parseAttendanceData(attData);
        }
      } catch (e) {
        debugPrint('Parse attendance note: $e');
      }

      // 2. Fees
      try {
        final feeData = results[1] as Map<String, dynamic>;
        if (feeData['summary'] != null) {
          final summary = feeData['summary'];
          final double balance = (summary['totalBalance'] ?? 0).toDouble();
          final statusStr = balance == 0 ? 'Paid' : 'Due';

          final historyList = (feeData['recentTransactions'] as List<dynamic>? ?? []).map((t) {
            return FeeHistory(
              id: t['id']?.toString() ?? '',
              amount: (t['amountPaid'] as num? ?? 0).toDouble(),
              date: t['paymentDate']?.toString() ?? '',
              reference: t['receiptNumber']?.toString() ?? 'REC-001',
              method: t['paymentMode']?.toString() ?? 'Online',
            );
          }).toList();

          _feesDb[studentId] = Fee(
            status: statusStr,
            amount: balance,
            dueDate: '10th of every month',
            history: historyList,
          );
        }
      } catch (e) {
        debugPrint('Parse fee note: $e');
      }

      // 3. Notices
      try {
        final noticesList = results[2] as List<dynamic>? ?? [];
        final parsed = noticesList
            .map<Notice>((n) => Notice.fromJson(n as Map<String, dynamic>))
            .toList();
        _childNoticesDb[studentId] = parsed;
        _noticesDb = parsed;
        for (final n in parsed) {
          if (n.isRead) {
            _readNoticeIds.add(n.id);
          }
        }
        await _saveReadNoticeIds();
      } catch (e) {
        debugPrint('Parse notice note: $e');
      }

      // 4. Teachers
      try {
        final teacherData = results[3] as Map<String, dynamic>;
        List<Teacher> teacherList = [];

        if (teacherData['teachers'] != null && (teacherData['teachers'] as List).isNotEmpty) {
          teacherList = (teacherData['teachers'] as List)
              .map((t) => Teacher.fromJson(t as Map<String, dynamic>))
              .toList();
        } else {
          // Deduplicate and consolidate by teacher id
          final Map<String, Map<String, dynamic>> consolidated = {};

          if (teacherData['classTeacher'] != null) {
            final ct = teacherData['classTeacher'];
            final String id = ct['id'].toString();
            consolidated[id] = {
              'id': id,
              'name': ct['name'].toString(),
              'isClassTeacher': true,
              'subjects': <String>[],
              'class': currentChild.grade,
            };
          }

          if (teacherData['subjectTeachers'] != null) {
            for (var st in teacherData['subjectTeachers']) {
              final String id = st['id'].toString();
              final String subj = (st['subject'] ?? '').toString().trim();
              if (consolidated.containsKey(id)) {
                if (subj.isNotEmpty && !(consolidated[id]!['subjects'] as List<String>).contains(subj)) {
                  (consolidated[id]!['subjects'] as List<String>).add(subj);
                }
              } else {
                consolidated[id] = {
                  'id': id,
                  'name': st['name'].toString(),
                  'isClassTeacher': false,
                  'subjects': subj.isNotEmpty ? <String>[subj] : <String>[],
                  'class': currentChild.grade,
                };
              }
            }
          }

          teacherList = consolidated.values.map((item) {
            final subs = item['subjects'] as List<String>;
            final bool isCT = item['isClassTeacher'] as bool;
            return Teacher(
              id: item['id'] as String,
              name: item['name'] as String,
              subject: subs.isNotEmpty ? subs.join(', ') : (isCT ? 'Class Teacher' : 'Subject Teacher'),
              subjects: subs,
              teacherClass: item['class'] as String,
              isClassTeacher: isCT,
            );
          }).toList();
        }

        if (teacherList.isNotEmpty) {
          _teachersDb[studentId] = teacherList;
        }
      } catch (e) {
        debugPrint('Parse teachers note: $e');
      }

      // 5. Events
      try {
        final eventsRaw = results[4] as List<dynamic>? ?? [];
        _eventsDb[studentId] = eventsRaw
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Parse events note: $e');
      }

      // 6. Health Record
      try {
        final healthRaw = results[5] as Map<String, dynamic>? ?? {};
        if (healthRaw.isNotEmpty) {
          _healthRecordsDb[studentId] = HealthRecord.fromJson(healthRaw);
        }
      } catch (e) {
        debugPrint('Parse health record note: $e');
      }

      // 7. Class Updates (Homework & Classwork)
      try {
        final updatesRaw = results[6] as List<dynamic>? ?? [];
        final parsedUpdates = updatesRaw
            .map((u) => ClassUpdate.fromJson(u as Map<String, dynamic>))
            .toList();
        parsedUpdates.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        _classUpdatesDb[studentId] = parsedUpdates;
      } catch (e) {
        debugPrint('Parse class updates note: $e');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Live child data fetch note: $e');
    }
  }

  /// Explicitly refresh health record for child
  Future<void> fetchChildHealth(String studentId, {bool silent = false}) async {
    try {
      if (!silent) {
        _isHealthLoading = true;
        notifyListeners();
      }
      final data = await ParentApiService.getChildHealth(studentId);
      _healthRecordsDb[studentId] = HealthRecord.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching child health: $e');
      if (!_healthRecordsDb.containsKey(studentId)) {
        _healthRecordsDb[studentId] = HealthRecord.empty(studentId);
      }
    } finally {
      if (!silent) {
        _isHealthLoading = false;
      }
      notifyListeners();
    }
  }

  void setSelectedAcademicYearId(String yearId) {
    if (_selectedAcademicYearId != yearId) {
      _selectedAcademicYearId = yearId;
      notifyListeners();
      fetchAcademicYearsAndHolidays(yearId: yearId);
    }
  }

  Future<void> fetchAcademicYearsAndHolidays({String? yearId, bool silent = false}) async {
    try {
      if (!silent) {
        _isHolidaysLoading = true;
        notifyListeners();
      }

      // 1. Fetch academic years
      final yearsRaw = await ParentApiService.getAcademicYears();
      if (yearsRaw.isNotEmpty) {
        _academicYears = yearsRaw
            .map((y) => AcademicYearItem.fromJson(y as Map<String, dynamic>))
            .toList();
      }

      // Determine target academic year
      String? targetYearId = yearId ?? _selectedAcademicYearId;
      if (targetYearId == null && _academicYears.isNotEmpty) {
        final current = _academicYears.firstWhere(
          (y) => y.isCurrent,
          orElse: () => _academicYears.first,
        );
        targetYearId = current.id;
      }
      _selectedAcademicYearId = targetYearId;

      // 2. Fetch holidays for the academic year
      final holidaysRaw = await ParentApiService.getHolidays(academicYearId: targetYearId);
      if (holidaysRaw.isNotEmpty) {
        final list = holidaysRaw
            .map((h) => Holiday.fromJson(h as Map<String, dynamic>))
            .toList();
        list.sort((a, b) => a.fullDate.compareTo(b.fullDate));
        if (targetYearId != null) {
          _academicYearHolidaysDb[targetYearId] = list;
        }
        _holidaysDb = list;
      }
    } catch (e) {
      debugPrint('Error fetching academic years / holidays: $e');
    } finally {
      if (!silent) {
        _isHolidaysLoading = false;
      }
      notifyListeners();
    }
  }

  // Change Language
  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _prefs?.setString('veyho_app_language', lang);
    notifyListeners();
  }

  // Change Selected Child
  Future<void> setCurrentChild(Child child) async {
    _currentChild = child;
    await _prefs?.setString('veyho_active_child_id', child.id);
    notifyListeners();
    fetchLiveChildData(child.id);
  }

  // User Authentication Sets
  Future<bool> login(String mobileNumber, String password) async {
    try {
      final res = await ApiService.post('/auth/login', {
        'mobile': mobileNumber,
        'password': password,
        'platform': 'mobile',
      }, requireAuth: false);

      if (res is Map<String, dynamic> && res['accessToken'] != null) {
        final accessToken = res['accessToken'] as String;
        final refreshToken = res['refreshToken'] as String?;
        await ApiService.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

        _loggedIn = true;
        _mobile = mobileNumber;
        _mustChangePassword = res['mustChangePassword'] as bool? ?? false;

        final userData = {
          'loggedIn': true,
          'mobile': mobileNumber,
          'mustChangePassword': _mustChangePassword,
        };
        await _prefs?.setString('veyho_parent_user', json.encode(userData));

        if (res['user'] != null) {
          if (res['user']['schoolName'] != null && res['user']['schoolName'].toString().isNotEmpty) {
            _schoolName = res['user']['schoolName'].toString();
            await _prefs?.setString('veyho_cached_school_name', _schoolName);
          }
          if (res['user']['children'] != null) {
            final List childrenList = res['user']['children'];
            if (childrenList.isNotEmpty) {
              _children = childrenList.map<Child>((c) {
                String dobFormatted = '—';
                if (c['dateOfBirth'] != null) {
                  final s = c['dateOfBirth'].toString();
                  if (s.contains('-') && s.length >= 10) {
                    final parts = s.substring(0, 10).split('-');
                    if (parts.length == 3) {
                      dobFormatted = '${parts[2]}-${parts[1]}-${parts[0]}';
                    }
                  } else {
                    dobFormatted = s;
                  }
                }

                return Child(
                  id: c['id'].toString(),
                  name: c['fullName'] ?? '${c['firstName']} ${c['lastName']}',
                  grade: '${c['className']} ${c['sectionName']}'.trim(),
                  enrollmentNo: c['grNumber']?.toString() ?? '1001',
                  dob: dobFormatted,
                  gender: c['gender'] ?? 'Male',
                  apaarId: c['apaarId']?.toString() ?? '—',
                  penNo: c['penNumber']?.toString() ?? '—',
                  studentId: c['id'].toString(),
                );
              }).toList();

              _currentChild = _children[0];
              await _prefs?.setString(
                'veyho_cached_children',
                json.encode(_children.map((c) => c.toJson()).toList()),
              );
              await _prefs?.setString('veyho_active_child_id', currentChild.id);
            }
          }
        }

        if (_children.isNotEmpty) {
          await fetchLiveChildData(currentChild.id);
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('API Login note: $e');
      rethrow;
    }

    return false;
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await ApiService.post('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (res != null) {
        _mustChangePassword = false;
        final userJson = _prefs?.getString('veyho_parent_user');
        if (userJson != null) {
          try {
            final Map<String, dynamic> userData = json.decode(userJson);
            userData['mustChangePassword'] = false;
            await _prefs?.setString('veyho_parent_user', json.encode(userData));
          } catch (_) {}
        }
        notifyListeners();
        return {'success': true};
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', ''),
      };
    }
    return {'success': false, 'error': 'Failed to change password'};
  }

  Future<void> logout() async {
    _loggedIn = false;
    _mobile = null;
    _schoolName = '';
    _schoolLogoUrl = null;
    _schoolLogoBase64 = null;
    for (var child in _children) {
      await _prefs?.remove('veyho_child_avatar_${child.id}');
    }
    _childAvatars.clear();
    _children = [];
    _currentChild = null;
    await ApiService.clearTokens();
    await _prefs?.remove('veyho_parent_user');
    await _prefs?.remove('veyho_cached_school_name');
    await _prefs?.remove('veyho_cached_school_logo');
    await _prefs?.remove('veyho_cached_school_logo_url');
    await _prefs?.remove('veyho_cached_children');
    await _prefs?.remove('veyho_active_child_id');
    notifyListeners();
  }

  // Update Child Avatar
  Future<void> updateChildAvatar(String childId, String? base64String) async {
    if (base64String != null) {
      _childAvatars[childId] = base64String;
      await _prefs?.setString('veyho_child_avatar_$childId', base64String);
    } else {
      _childAvatars.remove(childId);
      await _prefs?.remove('veyho_child_avatar_$childId');
    }
    notifyListeners();
  }

  bool _isAttendanceLoading = false;
  bool get isAttendanceLoading => _isAttendanceLoading;

  Attendance _parseAttendanceData(Map<String, dynamic> attData) {
    final summary = attData['summary'] as Map<String, dynamic>? ?? {};
    final records = (attData['records'] as List<dynamic>? ?? []);
    final targetMonth = (attData['month'] as num?)?.toInt() ?? DateTime.now().month;
    final targetYear = (attData['year'] as num?)?.toInt() ?? DateTime.now().year;

    final Map<String, AttendanceCalendarDay> calMap = {};

    // Mark Sundays as Weekend by default
    final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    int weekendCount = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final dt = DateTime(targetYear, targetMonth, d);
      if (dt.weekday == DateTime.sunday) {
        calMap[d.toString()] = AttendanceCalendarDay(
          status: 'W',
          reason: 'Sunday',
          date: dt,
        );
        weekendCount++;
      }
    }

    // Map attendance records from the server
    for (var r in records) {
      if (r['date'] != null) {
        final dateStr = r['date'].toString();
        final dt = DateTime.tryParse(dateStr);
        final dayNum = dateStr.split('-').last.replaceAll(RegExp(r'^0'), '');
        final s = (r['status'] ?? '').toString().toLowerCase();

        String charStatus = 'P';
        if (s == 'absent') {
          charStatus = 'A';
        } else if (s == 'late') {
          charStatus = 'L';
        } else if (s == 'half_day' || s == 'halfday') {
          charStatus = 'HD';
        } else if (s == 'school_holiday' || s == 'holiday') {
          charStatus = 'H';
        }

        calMap[dayNum] = AttendanceCalendarDay(
          status: charStatus,
          reason: r['reason']?.toString() ?? '',
          notes: r['notes']?.toString() ?? '',
          date: dt,
        );
      }
    }

    final present = (summary['present'] as num?)?.toInt() ?? 0;
    final absent = (summary['absent'] as num?)?.toInt() ?? 0;
    final late = (summary['late'] as num?)?.toInt() ?? 0;
    final halfDay = (summary['halfDay'] as num?)?.toInt() ?? 0;
    final holiday = (summary['holiday'] as num?)?.toInt() ?? 0;
    final totalWorkingDays = (summary['totalWorkingDays'] as num?)?.toInt() ?? (present + absent + late + halfDay);
    final percentage = (summary['attendancePercentage'] as num?)?.toInt() ?? (
      totalWorkingDays > 0 ? (((present + late + halfDay * 0.5) / totalWorkingDays) * 100).round() : 100
    );

    final monthName = DateFormat('MMMM yyyy').format(DateTime(targetYear, targetMonth));

    return Attendance(
      month: monthName,
      monthNumber: targetMonth,
      year: targetYear,
      summary: AttendanceSummary(
        present: present,
        absent: absent,
        late: late,
        halfDay: halfDay,
        holiday: holiday,
        weekend: weekendCount,
        totalWorkingDays: totalWorkingDays,
        attendancePercentage: percentage,
      ),
      calendar: calMap,
    );
  }

  Future<void> fetchAttendanceForMonth(String studentId, int month, int year) async {
    _isAttendanceLoading = true;
    notifyListeners();
    try {
      final attData = await ParentApiService.getChildAttendance(studentId, month: month, year: year);
      if (attData['summary'] != null) {
        _attendanceDb[studentId] = _parseAttendanceData(attData);
      }
    } catch (e) {
      debugPrint('Error fetching attendance for month: $e');
    } finally {
      _isAttendanceLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEvents(String studentId) async {
    _isEventsLoading = true;
    notifyListeners();
    try {
      final list = await ParentApiService.getChildEvents(studentId);
      final eventsList = list
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
      _eventsDb[studentId] = eventsList;
    } catch (e) {
      debugPrint('Error fetching events: $e');
    } finally {
      _isEventsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotices(String studentId) async {
    _isNoticesLoading = true;
    notifyListeners();
    try {
      final list = await ParentApiService.getChildNotices(studentId);
      final parsed = list
          .map<Notice>((n) => Notice.fromJson(n as Map<String, dynamic>))
          .toList();
      _childNoticesDb[studentId] = parsed;
      _noticesDb = parsed;
      for (final n in parsed) {
        if (n.isRead) {
          _readNoticeIds.add(n.id);
        }
      }
      await _saveReadNoticeIds();
    } catch (e) {
      debugPrint('Error fetching notices: $e');
    } finally {
      _isNoticesLoading = false;
      notifyListeners();
    }
  }

  bool _isClassUpdatesLoading = false;
  bool get isClassUpdatesLoading => _isClassUpdatesLoading;

  Future<void> fetchClassUpdates(String studentId) async {
    _isClassUpdatesLoading = true;
    notifyListeners();
    try {
      final list = await ParentApiService.getChildClassUpdates(studentId);
      final parsed = list
          .map<ClassUpdate>((u) => ClassUpdate.fromJson(u as Map<String, dynamic>))
          .toList();
      parsed.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _classUpdatesDb[studentId] = parsed;
    } catch (e) {
      debugPrint('Error fetching class updates: $e');
    } finally {
      _isClassUpdatesLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadReadNoticeIds() async {
    final key = 'veyho_parent_read_notices_${_mobile ?? 'user'}';
    final list = _prefs?.getStringList(key) ?? [];
    _readNoticeIds = list.toSet();
  }

  Future<void> _saveReadNoticeIds() async {
    final key = 'veyho_parent_read_notices_${_mobile ?? 'user'}';
    await _prefs?.setStringList(key, _readNoticeIds.toList());
  }

  Future<void> markNoticeAsRead(String id) async {
    if (id.isEmpty || _readNoticeIds.contains(id)) return;
    _readNoticeIds.add(id);
    await _saveReadNoticeIds();
    notifyListeners();
    ParentApiService.markNoticeRead(id).catchError((_) => false);
  }

  Future<void> markAllNoticesAsRead() async {
    final unread = notices.where((n) => !_readNoticeIds.contains(n.id)).map((n) => n.id).toList();
    if (unread.isEmpty) return;
    _readNoticeIds.addAll(unread);
    await _saveReadNoticeIds();
    notifyListeners();
    if (currentChild.id.isNotEmpty) {
      ParentApiService.markAllNoticesRead(currentChild.id).catchError((_) => false);
    }
  }

  List<Notice> get notices => _childNoticesDb[currentChild.id] ?? _noticesDb;
  List<ClassUpdate> get classUpdates => _classUpdatesDb[currentChild.id] ?? [];
  List<Teacher> get teachers => _teachersDb[currentChild.id] ?? (_teachersDb.values.isNotEmpty ? _teachersDb.values.first : []);
  Attendance get attendance => _attendanceDb[currentChild.id] ?? (_attendanceDb.values.isNotEmpty ? _attendanceDb.values.first : Attendance(month: '—', summary: AttendanceSummary(present: 0, absent: 0, holiday: 0, weekend: 0), calendar: {}));
  List<Event> get events => _eventsDb[currentChild.id] ?? (_eventsDb.values.isNotEmpty ? _eventsDb.values.first : []);
  Fee get fees => _feesDb[currentChild.id] ?? (_feesDb.values.isNotEmpty ? _feesDb.values.first : Fee(status: '—', amount: 0.0, dueDate: '—', history: []));
  List<Album> get albums => _albumsDb;
  List<Holiday> get holidays => getHolidaysForYear(_selectedAcademicYearId);

  List<Holiday> getHolidaysForYear(String? yearId) {
    if (yearId != null && _academicYearHolidaysDb.containsKey(yearId)) {
      return _academicYearHolidaysDb[yearId]!;
    }
    return _holidaysDb;
  }
  List<ExamResult> get examResults => _examResultsDb;
  List<Book> get books => _booksDb[currentChild.id] ?? [];

  // Message Teacher
  void addParentMessage(String teacherId, String text) {
    final list = _teachersDb[currentChild.id] ?? [];
    final idx = list.indexWhere((t) => t.id == teacherId);
    if (idx != -1) {
      final now = DateTime.now();
      final timeStr = "${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
      
      final newMsg = Message(
        id: "M${now.millisecondsSinceEpoch}",
        text: text,
        sender: 'parent',
        timestamp: timeStr,
      );

      list[idx].messages.add(newMsg);
      list[idx].lastMessage = text;
      notifyListeners();
    }

    if (currentChild.id.isNotEmpty) {
      ParentApiService.sendMessage(currentChild.id, text).catchError((e) {
        debugPrint('API message send note: $e');
        return <String, dynamic>{};
      });
    }
  }

  // Reserve Library Book
  void reserveBook(String bookId) {
    final list = _booksDb[currentChild.id] ?? [];
    final idx = list.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      
      list[idx].status = 'Reserved';
      final original = list[idx];
      list[idx] = Book(
        id: original.id,
        title: original.title,
        author: original.author,
        status: 'Reserved',
        reserveDate: dateStr,
        issueDate: original.issueDate,
        dueDate: original.dueDate,
      );
      notifyListeners();
    }
  }

  // Pay School Fees
  void payFees(double amount, String method) {
    final feeObj = _feesDb[currentChild.id];
    if (feeObj != null && feeObj.status == 'Due') {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      feeObj.status = 'Paid';
      feeObj.amount = 0;
      
      final historyItem = FeeHistory(
        id: "REF-${now.millisecondsSinceEpoch}",
        amount: amount,
        date: dateStr,
        reference: "REF-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.millisecond}",
        method: method,
      );
      
      feeObj.history.insert(0, historyItem);
      notifyListeners();
    }
  }

  // Initialize Mock Data (for demo/testing only)
  void initMockDatabase() {
    // 1. Children Specs
    _children = [
      Child(
        id: 'aarav',
        name: 'Aarav Sharma',
        grade: 'Grade 3-B',
        enrollmentNo: 'VIS2021001',
        dob: '15-08-2017',
        gender: 'Male',
        apaarId: 'AP-2021-VIS-001',
        penNo: 'PEN-MH-001-2021',
        studentId: 'STU-001-3B',
      ),
      Child(
        id: 'priya',
        name: 'Priya Sharma',
        grade: 'Grade 5-A',
        enrollmentNo: 'VIS2019045',
        dob: '22-03-2015',
        gender: 'Female',
        apaarId: 'AP-2019-VIS-045',
        penNo: 'PEN-MH-045-2019',
        studentId: 'STU-045-5A',
      ),
    ];

    // 2. Notices
    _noticesDb = [
      Notice(
        id: '1',
        source: 'Principal Office',
        title: 'Annual Day - Important Information',
        date: '2026-10-25',
        time: '09:00 AM',
        body: 'Event schedule, reporting time and participation details for the upcoming Annual Day function.',
        category: 'School Notice',
        publishedAt: '2026-10-25T09:00:00Z',
      ),
      Notice(
        id: '2',
        source: 'Class Teacher',
        title: 'Orange Colour Day',
        date: '2026-10-24',
        time: '11:30 AM',
        body: 'Children to come in orange dress and bring orange coloured props or fruit for class activities.',
        category: 'Class Notice',
        publishedAt: '2026-10-24T11:30:00Z',
      ),
      Notice(
        id: '3',
        source: 'Administration',
        title: 'Public Holiday - Gandhi Jayanti',
        date: '2026-10-02',
        time: '10:00 AM',
        body: 'School will remain closed on 2nd October on account of Gandhi Jayanti.',
        category: 'School Notice',
        publishedAt: '2026-10-02T10:00:00Z',
      ),
      Notice(
        id: '4',
        source: 'Art Teacher',
        title: 'Drawing Competition',
        date: '2026-09-28',
        time: '02:00 PM',
        body: 'Theme: My Dream World. Submit your creative entries to class teacher by 30th Sep.',
        category: 'Class Notice',
        publishedAt: '2026-09-28T14:00:00Z',
      ),
      Notice(
        id: '5',
        source: 'Principal Office',
        title: 'Parent-Teacher Meeting',
        date: '2026-09-15',
        time: '10:00 AM',
        body: 'Dear Parents, We are organizing a Parent-Teacher Meeting to discuss your child\'s academic progress.',
        category: 'School Notice',
        publishedAt: '2026-09-15T10:00:00Z',
        cta: NoticeCta(label: 'View Event', action: 'event'),
      ),
    ];

    // 3. Class Updates
    _classUpdatesDb = {
      'aarav': [
        ClassUpdate(
          id: '1',
          type: 'Homework',
          subject: 'Mathematics',
          classTarget: 'Grade 3-B',
          teacher: 'Mrs. Priya Patel',
          body: 'Complete exercises 1-10 from Chapter 5: Multiplication Tables. Show all working steps.',
          date: '2026-05-08',
          attachments: ['worksheet_multiplication.pdf'],
        ),
        ClassUpdate(
          id: '2',
          type: 'Classwork',
          subject: 'English',
          classTarget: 'Grade 3-B',
          teacher: 'Mr. Arjun Desai',
          body: 'Today we learned about nouns and pronouns. Students participated in group activities to identify different types of nouns.',
          date: '2026-05-07',
        ),
        ClassUpdate(
          id: '3',
          type: 'Homework',
          subject: 'Science',
          classTarget: 'Grade 3-B',
          teacher: 'Dr. Kavita Singh',
          body: 'Draw and label the parts of a plant. Also, write 5 sentences about the importance of plants.',
          date: '2026-05-06',
          attachments: ['plant_diagram_template.pdf'],
        ),
      ],
      'priya': [
        ClassUpdate(
          id: '4',
          type: 'Homework',
          subject: 'History',
          classTarget: 'Grade 5-A',
          teacher: 'Mr. Rajesh Kumar',
          body: 'Write a short essay (200 words) on the Indian Freedom Movement. Include key leaders and events.',
          date: '2026-05-08',
        ),
        ClassUpdate(
          id: '5',
          type: 'Classwork',
          subject: 'Mathematics',
          classTarget: 'Grade 5-A',
          teacher: 'Mrs. Sunita Verma',
          body: 'Completed Chapter 8 on Fractions and Decimals. Students solved practice problems on converting fractions to decimals.',
          date: '2026-05-07',
        ),
        ClassUpdate(
          id: '6',
          type: 'Homework',
          subject: 'English',
          classTarget: 'Grade 5-A',
          teacher: 'Ms. Anjali Mehta',
          body: 'Read Chapter 3 from the textbook and answer questions 1-5. Also, learn 10 new vocabulary words.',
          date: '2026-05-06',
        ),
      ]
    };

    // 4. Teachers
    _teachersDb = {
      'aarav': [
        Teacher(
          id: '1',
          name: 'Mrs. Priya Patel',
          subject: 'Mathematics',
          teacherClass: 'Grade 3-B',
          isClassTeacher: true,
          lastMessage: 'Aarav is doing great in math!',
          messages: [
            Message(id: '1', text: 'Good morning Mrs. Patel, I wanted to discuss Aarav\'s performance.', sender: 'parent', timestamp: '10:30 AM'),
            Message(id: '2', text: 'Good morning! Aarav is doing excellent. He scored 95% in the last test.', sender: 'teacher', timestamp: '10:45 AM'),
            Message(id: '3', text: 'That\'s wonderful! Please keep me updated on his progress.', sender: 'parent', timestamp: '11:00 AM'),
            Message(id: '4', text: 'Sure, I will. He\'s very attentive in class.', sender: 'teacher', timestamp: '11:15 AM'),
            Message(id: '5', text: 'Aarav is doing great in math!', sender: 'teacher', timestamp: '09:30 AM'),
          ],
        ),
        Teacher(
          id: '2',
          name: 'Mr. Arjun Desai',
          subject: 'English',
          teacherClass: 'Grade 3-B',
          lastMessage: 'Please encourage reading at home',
          messages: [
            Message(id: '1', text: 'Hello Mr. Desai, how is Aarav doing in English?', sender: 'parent', timestamp: '02:00 PM'),
            Message(id: '2', text: 'He\'s improving! I suggest more reading practice at home.', sender: 'teacher', timestamp: '03:00 PM'),
            Message(id: '3', text: 'Thank you, I will ensure he reads daily.', sender: 'parent', timestamp: '03:30 PM'),
            Message(id: '4', text: 'Please encourage reading at home', sender: 'teacher', timestamp: '04:00 PM'),
          ],
        ),
        Teacher(
          id: '3',
          name: 'Dr. Kavita Singh',
          subject: 'Science',
          teacherClass: 'Grade 3-B',
          lastMessage: 'Great work on the plant project!',
          messages: [
            Message(id: '1', text: 'Dr. Singh, Aarav loved the science experiment today!', sender: 'parent', timestamp: '05:00 PM'),
            Message(id: '2', text: 'I\'m glad! Science should be fun and engaging.', sender: 'teacher', timestamp: '05:30 PM'),
            Message(id: '3', text: 'Great work on the plant project!', sender: 'teacher', timestamp: '10:00 AM'),
          ],
        ),
      ],
      'priya': [
        Teacher(
          id: '4',
          name: 'Mrs. Sunita Verma',
          subject: 'Mathematics',
          teacherClass: 'Grade 5-A',
          isClassTeacher: true,
          lastMessage: 'Priya needs more practice with fractions',
          messages: [
            Message(id: '1', text: 'Hello Mrs. Verma, Priya struggled with fractions. Any suggestions?', sender: 'parent', timestamp: '11:00 AM'),
            Message(id: '2', text: 'Yes, I noticed. Let\'s work together on this. I\'ll provide extra worksheets.', sender: 'teacher', timestamp: '12:00 PM'),
            Message(id: '3', text: 'Thank you for your support!', sender: 'parent', timestamp: '12:30 PM'),
            Message(id: '4', text: 'Priya needs more practice with fractions', sender: 'teacher', timestamp: '09:00 AM'),
          ],
        ),
        Teacher(
          id: '5',
          name: 'Ms. Anjali Mehta',
          subject: 'English',
          teacherClass: 'Grade 5-A',
          lastMessage: 'Excellent essay writing skills!',
          messages: [
            Message(id: '1', text: 'Ms. Mehta, Priya enjoyed writing the essay assignment.', sender: 'parent', timestamp: '04:00 PM'),
            Message(id: '2', text: 'Her essay was one of the best in class!', sender: 'teacher', timestamp: '05:00 PM'),
            Message(id: '3', text: 'Excellent essay writing skills!', sender: 'teacher', timestamp: '10:00 AM'),
          ],
        ),
      ]
    };

    // 5. Attendance
    _attendanceDb = {
      'aarav': Attendance(
        month: 'January 2026',
        summary: AttendanceSummary(present: 20, absent: 2, holiday: 4, weekend: 9),
        calendar: {
          '1': AttendanceCalendarDay(status: 'W', reason: ''),
          '2': AttendanceCalendarDay(status: 'W', reason: ''),
          '3': AttendanceCalendarDay(status: 'P', reason: ''),
          '4': AttendanceCalendarDay(status: 'P', reason: ''),
          '5': AttendanceCalendarDay(status: 'P', reason: ''),
          '6': AttendanceCalendarDay(status: 'P', reason: ''),
          '7': AttendanceCalendarDay(status: 'P', reason: ''),
          '8': AttendanceCalendarDay(status: 'W', reason: ''),
          '9': AttendanceCalendarDay(status: 'W', reason: ''),
          '10': AttendanceCalendarDay(status: 'P', reason: ''),
          '11': AttendanceCalendarDay(status: 'A', reason: 'Sick leave'),
          '12': AttendanceCalendarDay(status: 'P', reason: ''),
          '13': AttendanceCalendarDay(status: 'P', reason: ''),
          '14': AttendanceCalendarDay(status: 'P', reason: ''),
          '15': AttendanceCalendarDay(status: 'W', reason: ''),
          '16': AttendanceCalendarDay(status: 'W', reason: ''),
          '17': AttendanceCalendarDay(status: 'P', reason: ''),
          '18': AttendanceCalendarDay(status: 'P', reason: ''),
          '19': AttendanceCalendarDay(status: 'P', reason: ''),
          '20': AttendanceCalendarDay(status: 'P', reason: ''),
          '21': AttendanceCalendarDay(status: 'P', reason: ''),
          '22': AttendanceCalendarDay(status: 'W', reason: ''),
          '23': AttendanceCalendarDay(status: 'W', reason: ''),
          '24': AttendanceCalendarDay(status: 'P', reason: ''),
          '25': AttendanceCalendarDay(status: 'P', reason: ''),
          '26': AttendanceCalendarDay(status: 'H', reason: 'Republic Day'),
          '27': AttendanceCalendarDay(status: 'P', reason: ''),
          '28': AttendanceCalendarDay(status: 'A', reason: 'Family function'),
          '29': AttendanceCalendarDay(status: 'W', reason: ''),
          '30': AttendanceCalendarDay(status: 'W', reason: ''),
          '31': AttendanceCalendarDay(status: 'P', reason: ''),
        },
      ),
      'priya': Attendance(
        month: 'January 2026',
        summary: AttendanceSummary(present: 21, absent: 1, holiday: 4, weekend: 9),
        calendar: {
          '1': AttendanceCalendarDay(status: 'W', reason: ''),
          '2': AttendanceCalendarDay(status: 'W', reason: ''),
          '3': AttendanceCalendarDay(status: 'P', reason: ''),
          '4': AttendanceCalendarDay(status: 'P', reason: ''),
          '5': AttendanceCalendarDay(status: 'P', reason: ''),
          '6': AttendanceCalendarDay(status: 'P', reason: ''),
          '7': AttendanceCalendarDay(status: 'P', reason: ''),
          '8': AttendanceCalendarDay(status: 'W', reason: ''),
          '9': AttendanceCalendarDay(status: 'W', reason: ''),
          '10': AttendanceCalendarDay(status: 'P', reason: ''),
          '11': AttendanceCalendarDay(status: 'P', reason: ''),
          '12': AttendanceCalendarDay(status: 'P', reason: ''),
          '13': AttendanceCalendarDay(status: 'P', reason: ''),
          '14': AttendanceCalendarDay(status: 'P', reason: ''),
          '15': AttendanceCalendarDay(status: 'W', reason: ''),
          '16': AttendanceCalendarDay(status: 'W', reason: ''),
          '17': AttendanceCalendarDay(status: 'P', reason: ''),
          '18': AttendanceCalendarDay(status: 'A', reason: 'Medical appointment'),
          '19': AttendanceCalendarDay(status: 'P', reason: ''),
          '20': AttendanceCalendarDay(status: 'P', reason: ''),
          '21': AttendanceCalendarDay(status: 'P', reason: ''),
          '22': AttendanceCalendarDay(status: 'W', reason: ''),
          '23': AttendanceCalendarDay(status: 'W', reason: ''),
          '24': AttendanceCalendarDay(status: 'P', reason: ''),
          '25': AttendanceCalendarDay(status: 'P', reason: ''),
          '26': AttendanceCalendarDay(status: 'H', reason: 'Republic Day'),
          '27': AttendanceCalendarDay(status: 'P', reason: ''),
          '28': AttendanceCalendarDay(status: 'P', reason: ''),
          '29': AttendanceCalendarDay(status: 'W', reason: ''),
          '30': AttendanceCalendarDay(status: 'W', reason: ''),
          '31': AttendanceCalendarDay(status: 'P', reason: ''),
        },
      )
    };

    // 6. Events
    _eventsDb = {
      'aarav': [
        Event(
          id: '1',
          title: 'Parent-Teacher Meeting',
          date: '15 May 2026',
          time: '10:00 AM - 2:00 PM',
          location: 'School Auditorium',
          description: 'Quarterly Parent-Teacher Meeting to discuss student progress and academic performance.',
          category: 'ACADEMIC',
          scope: 'SCHOOL',
        ),
        Event(
          id: '2',
          title: 'Annual Sports Day',
          date: '20 May 2026',
          time: '8:00 AM - 4:00 PM',
          location: 'School Sports Ground',
          description: 'Annual Sports Day with various athletic events and competitions. All students to participate.',
          category: 'SPORTS',
          scope: 'SCHOOL',
        ),
      ],
    };

    // 7. Fees
    _feesDb = {
      'aarav': Fee(
        status: 'Due',
        amount: 4500.0,
        dueDate: '2026-05-15',
        history: [
          FeeHistory(id: '1', amount: 5000.0, date: '2026-01-10', reference: 'REF-2026-JAN-001', method: 'UPI'),
          FeeHistory(id: '2', amount: 5000.0, date: '2025-10-12', reference: 'REF-2025-OCT-001', method: 'Net Banking'),
        ],
      ),
      'priya': Fee(
        status: 'Paid',
        amount: 0.0,
        history: [
          FeeHistory(id: '3', amount: 6000.0, date: '2026-04-05', reference: 'REF-2026-APR-002', method: 'Debit Card'),
          FeeHistory(id: '4', amount: 6000.0, date: '2026-01-08', reference: 'REF-2026-JAN-002', method: 'UPI'),
          FeeHistory(id: '5', amount: 6000.0, date: '2025-10-10', reference: 'REF-2025-OCT-002', method: 'UPI'),
        ],
      ),
    };

    // 8. Albums
    _albumsDb = [
      Album(
        id: '1',
        title: 'Annual Day 2026',
        coverPhoto: 'photo-annual-cover',
        photoCount: 24,
        photos: List.generate(24, (i) => Photo(id: '${i + 1}', url: 'photo-annual-${i + 1}')),
      ),
      Album(
        id: '2',
        title: 'Sports Day 2025',
        coverPhoto: 'photo-sports-cover',
        photoCount: 18,
        photos: List.generate(18, (i) => Photo(id: '${i + 1}', url: 'photo-sports-${i + 1}')),
      ),
      Album(
        id: '3',
        title: 'Independence Day Celebration',
        coverPhoto: 'photo-independence-cover',
        photoCount: 15,
        photos: List.generate(15, (i) => Photo(id: '${i + 1}', url: 'photo-independence-${i + 1}')),
      ),
    ];

    // 9. Academic Years & Holidays (2026-27 Academic Year Sequence: Apr/Jun 2026 to Mar 2027)
    _academicYears = [
      AcademicYearItem(
        id: '224496ea-51ce-4eaa-9a09-006dcd02f2b5',
        name: '2026-27',
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2027, 3, 31),
        isCurrent: true,
      ),
      AcademicYearItem(
        id: '246febdb-fc26-4202-ab9f-7e7ad6445a24',
        name: '2027-28',
        startDate: DateTime(2027, 6, 15),
        endDate: DateTime(2028, 4, 30),
        isCurrent: false,
      ),
    ];
    _selectedAcademicYearId = '224496ea-51ce-4eaa-9a09-006dcd02f2b5';

    _holidaysDb = [
      Holiday(id: 'h1', date: '03', month: 'Apr', day: 'Friday', title: 'Good Friday', type: 'National', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 4, 3)),
      Holiday(id: 'h2', date: '14', month: 'Apr', day: 'Tuesday', title: 'Ambedkar Jayanti', type: 'Bank Holiday', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 4, 14)),
      Holiday(id: 'h3', date: '01', month: 'May', day: 'Friday', title: 'Labour Day / Maharashtra Day', type: 'Bank Holiday', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 5, 1)),
      Holiday(id: 'h4', date: '28', month: 'May', day: 'Thursday', title: 'Bakrid (Eid-ul-Adha)', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 5, 28)),
      Holiday(id: 'h5', date: '26', month: 'Jun', day: 'Friday', title: 'Muharram', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 6, 26)),
      Holiday(id: 'h6', date: '15', month: 'Aug', day: 'Saturday', title: 'Independence Day', type: 'National', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 8, 15)),
      Holiday(id: 'h7', date: '26', month: 'Aug', day: 'Wednesday', title: 'Milad-un-Nabi (Id-e-Milad)', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 8, 26)),
      Holiday(id: 'h8', date: '28', month: 'Aug', day: 'Friday', title: 'Raksha Bandhan', type: 'Bank Holiday', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 8, 28)),
      Holiday(id: 'h9', date: '04', month: 'Sep', day: 'Friday', title: 'Janmashtami', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 9, 4)),
      Holiday(id: 'h10', date: '14', month: 'Sep', day: 'Monday', title: 'Ganesh Chaturthi', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 9, 14)),
      Holiday(id: 'h11', date: '02', month: 'Oct', day: 'Friday', title: 'Gandhi Jayanti', type: 'National', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 10, 2)),
      Holiday(id: 'h12', date: '20', month: 'Oct', day: 'Tuesday', title: 'Dussehra (Vijayadashami)', type: 'Festival', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 10, 20)),
      Holiday(id: 'h13', date: '08', month: 'Nov', day: 'Sunday', title: 'Diwali (Deepavali)', type: 'Festival', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 11, 8)),
      Holiday(id: 'h14', date: '09', month: 'Nov', day: 'Monday', title: 'Govardhan Puja', type: 'Bank Holiday', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 11, 9)),
      Holiday(id: 'h15', date: '10', month: 'Nov', day: 'Tuesday', title: 'Bhai Dooj', type: 'Bank Holiday', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 11, 10)),
      Holiday(id: 'h16', date: '24', month: 'Nov', day: 'Tuesday', title: 'Guru Nanak Jayanti', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 11, 24)),
      Holiday(id: 'h17', date: '25', month: 'Dec', day: 'Friday', title: 'Christmas', type: 'National', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2026, 12, 25)),
      Holiday(id: 'h18', date: '14', month: 'Jan', day: 'Thursday', title: 'Makar Sankranti / Pongal', type: 'Bank Holiday', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2027, 1, 14)),
      Holiday(id: 'h19', date: '26', month: 'Jan', day: 'Tuesday', title: 'Republic Day', type: 'National', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2027, 1, 26)),
      Holiday(id: 'h20', date: '06', month: 'Mar', day: 'Saturday', title: 'Maha Shivratri', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2027, 3, 6)),
      Holiday(id: 'h21', date: '10', month: 'Mar', day: 'Wednesday', title: 'Id-ul-Fitr (Ramzan Eid)', type: 'Gazetted', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2027, 3, 10)),
      Holiday(id: 'h22', date: '22', month: 'Mar', day: 'Monday', title: 'Holi', type: 'Festival', academicYearId: '224496ea-51ce-4eaa-9a09-006dcd02f2b5', fullDate: DateTime(2027, 3, 22)),
    ];
    _academicYearHolidaysDb['224496ea-51ce-4eaa-9a09-006dcd02f2b5'] = _holidaysDb;

    // 10. Exam results
    _examResultsDb = [];

    // 11. Books
    _booksDb = {
      'aarav': [
        Book(id: 'b1', title: 'The Secret Garden', author: 'Frances Hodgson Burnett', status: 'Issued', issueDate: '01-05-2026', dueDate: '15-05-2026'),
        Book(id: 'b2', title: 'Charlie and the Chocolate Factory', author: 'Roald Dahl', status: 'Reserved', reserveDate: '08-05-2026'),
      ],
      'priya': [
        Book(id: 'b3', title: 'Percy Jackson & the Olympians', author: 'Rick Riordan', status: 'Issued', issueDate: '28-04-2026', dueDate: '12-05-2026'),
      ]
    };
  }
}
