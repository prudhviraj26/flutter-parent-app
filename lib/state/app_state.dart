import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Language & Session
  String _language = 'en';
  bool _loggedIn = false;
  String? _mobile;

  // Selected Child Specs
  late Child _currentChild;
  List<Child> _children = [];

  // Child Avatars mapping
  final Map<String, String> _childAvatars = {};

  // Mock Database lists
  List<Child> _childrenDb = [];
  List<Notice> _noticesDb = [];
  Map<String, List<ClassUpdate>> _classUpdatesDb = {};
  Map<String, List<Teacher>> _teachersDb = {};
  Map<String, Attendance> _attendanceDb = {};
  List<Event> _eventsDb = [];
  Map<String, Fee> _feesDb = {};
  List<Album> _albumsDb = [];
  List<Holiday> _holidaysDb = [];
  List<ExamResult> _examResultsDb = [];
  Map<String, List<Book>> _booksDb = {};

  // Getters
  String get language => _language;
  bool get loggedIn => _loggedIn;
  String? get mobile => _mobile;
  Child get currentChild => _currentChild;
  List<Child> get children => _children;
  Map<String, String> get childAvatars => _childAvatars;

  final SchoolConfig schoolConfig = SchoolConfig(
    name: 'Demo International School',
    nameMarathi: 'डेमो आंतरराष्ट्रीय शाळा',
    logo: '',
  );

  final Map<String, String> veyhoBranding = {
    'companyName': 'Veyho Technologies',
    'companyNameMarathi': 'वेहो टेक्नॉलॉजीज',
    'tagline': 'Powered by Veyho',
    'taglineMarathi': 'वेहो द्वारे संचालित'
  };

  AppState() {
    _initMockDatabase();
    _currentChild = _childrenDb[0];
    _children = _childrenDb;
    _initPreferences();
  }

  // Load preferences from local storage
  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Load language preference
    _language = _prefs?.getString('veyho_app_language') ?? 'en';

    // Load login session
    final userJson = _prefs?.getString('veyho_parent_user');
    if (userJson != null) {
      try {
        final Map<String, dynamic> userData = json.decode(userJson);
        _loggedIn = userData['loggedIn'] as bool? ?? false;
        _mobile = userData['mobile'] as String?;
      } catch (e) {
        _prefs?.remove('veyho_parent_user');
      }
    }

    // Load active child ID
    final savedChildId = _prefs?.getString('veyho_active_child_id');
    if (savedChildId != null) {
      final idx = _childrenDb.indexWhere((c) => c.id == savedChildId);
      if (idx != -1) {
        _currentChild = _childrenDb[idx];
      }
    }

    // Load child avatars
    for (var child in _childrenDb) {
      final avatarBase64 = _prefs?.getString('veyho_child_avatar_${child.id}');
      if (avatarBase64 != null) {
        _childAvatars[child.id] = avatarBase64;
      }
    }

    notifyListeners();
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
  }

  // User Authentication Sets
  Future<void> login(String mobileNumber) async {
    _loggedIn = true;
    _mobile = mobileNumber;

    final userData = {
      'loggedIn': true,
      'mobile': mobileNumber,
    };
    await _prefs?.setString('veyho_parent_user', json.encode(userData));
    notifyListeners();
  }

  Future<void> logout() async {
    _loggedIn = false;
    _mobile = null;
    await _prefs?.remove('veyho_parent_user');
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

  // Get active student data
  List<Notice> get notices => _noticesDb;
  List<ClassUpdate> get classUpdates => _classUpdatesDb[_currentChild.id] ?? [];
  List<Teacher> get teachers => _teachersDb[_currentChild.id] ?? [];
  Attendance get attendance => _attendanceDb[_currentChild.id]!;
  List<Event> get events => _eventsDb;
  Fee get fees => _feesDb[_currentChild.id]!;
  List<Album> get albums => _albumsDb;
  List<Holiday> get holidays => _holidaysDb;
  List<ExamResult> get examResults => _examResultsDb;
  List<Book> get books => _booksDb[_currentChild.id] ?? [];

  // Message Teacher
  void addParentMessage(String teacherId, String text) {
    final list = _teachersDb[_currentChild.id] ?? [];
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
  }

  // Reserve Library Book
  void reserveBook(String bookId) {
    final list = _booksDb[_currentChild.id] ?? [];
    final idx = list.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      
      list[idx].status = 'Reserved';
      // in Dart, we create a new Book instance to assign back because of immutable fields, or write custom update methods
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
    final feeObj = _feesDb[_currentChild.id];
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

  // Initialize Mock Data
  void _initMockDatabase() {
    // 1. Children Specs
    _childrenDb = [
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
        title: 'Parent-Teacher Meeting',
        date: '2026-05-15',
        time: '10:00 AM',
        body: 'Dear Parents, We are organizing a Parent-Teacher Meeting on May 15, 2026 at 10:00 AM. Please make sure to attend and discuss your child\'s progress with their teachers.',
        cta: NoticeCta(label: 'View Event', action: 'event'),
      ),
      Notice(
        id: '2',
        source: 'Accounts Department',
        title: 'Fee Payment Reminder',
        date: '2026-05-10',
        time: '09:00 AM',
        body: 'This is a reminder to pay the pending school fees before the due date. Late payment will attract a fine of ₹100 per day.',
        cta: NoticeCta(label: 'View Fees', action: 'fees'),
      ),
      Notice(
        id: '3',
        source: 'Sports Department',
        title: 'Annual Sports Day',
        date: '2026-05-20',
        time: '08:00 AM',
        body: 'Annual Sports Day will be held on May 20, 2026. All students are required to participate. Parents are cordially invited to attend.',
      ),
      Notice(
        id: '4',
        source: 'Administration',
        title: 'Summer Vacation Notice',
        date: '2026-05-25',
        time: '12:00 PM',
        body: 'School will be closed for summer vacation from June 1 to June 30, 2026. School will reopen on July 1, 2026.',
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
    _eventsDb = [
      Event(
        id: '1',
        title: 'Parent-Teacher Meeting',
        date: '2026-05-15',
        time: '10:00 AM - 2:00 PM',
        location: 'School Auditorium',
        description: 'Quarterly Parent-Teacher Meeting to discuss student progress and academic performance.',
      ),
      Event(
        id: '2',
        title: 'Annual Sports Day',
        date: '2026-05-20',
        time: '8:00 AM - 4:00 PM',
        location: 'School Sports Ground',
        description: 'Annual Sports Day with various athletic events and competitions. All students to participate.',
      ),
    ];

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

    // 9. Holidays
    _holidaysDb = [
      Holiday(id: '1', date: '26', month: 'Jan', day: 'Monday', title: 'Republic Day', type: 'National'),
      Holiday(id: '2', date: '14', month: 'Mar', day: 'Friday', title: 'Holi', type: 'Festival'),
      Holiday(id: '3', date: '29', month: 'Mar', day: 'Saturday', title: 'Good Friday', type: 'National'),
      Holiday(id: '4', date: '14', month: 'Apr', day: 'Monday', title: 'Dr. Ambedkar Jayanti', type: 'National'),
      Holiday(id: '5', date: '01', month: 'May', day: 'Thursday', title: 'Maharashtra Day', type: 'National'),
      Holiday(id: '6', date: '23', month: 'May', day: 'Friday', title: 'Buddha Purnima', type: 'Festival'),
      Holiday(id: '7', date: '15', month: 'Aug', day: 'Friday', title: 'Independence Day', type: 'National'),
      Holiday(id: '8', date: '16', month: 'Aug', day: 'Saturday', title: 'Janmashtami', type: 'Festival'),
      Holiday(id: '9', date: '02', month: 'Oct', day: 'Thursday', title: 'Gandhi Jayanti', type: 'National'),
      Holiday(id: '10', date: '24', month: 'Oct', day: 'Friday', title: 'Dussehra', type: 'Festival'),
      Holiday(id: '11', date: '13', month: 'Nov', day: 'Thursday', title: 'Diwali', type: 'Festival'),
      Holiday(id: '12', date: '25', month: 'Dec', day: 'Thursday', title: 'Christmas', type: 'National'),
    ];

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
