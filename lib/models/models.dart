import 'package:intl/intl.dart';

class Child {
  final String id;
  final String name;
  final String grade;
  final String enrollmentNo;
  final String dob;
  final String gender;
  final String apaarId;
  final String penNo;
  final String studentId;

  Child({
    required this.id,
    required this.name,
    required this.grade,
    required this.enrollmentNo,
    required this.dob,
    required this.gender,
    required this.apaarId,
    required this.penNo,
    required this.studentId,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      grade: json['grade'] as String,
      enrollmentNo: json['enrollmentNo'] as String,
      dob: json['dob'] as String,
      gender: json['gender'] as String,
      apaarId: json['apaarId'] as String,
      penNo: json['penNo'] as String,
      studentId: json['studentId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'enrollmentNo': enrollmentNo,
      'dob': dob,
      'gender': gender,
      'apaarId': apaarId,
      'penNo': penNo,
      'studentId': studentId,
    };
  }
}

class Message {
  final String id;
  final String text;
  final String sender; // 'teacher' | 'parent'
  final String timestamp;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: json['sender'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timestamp': timestamp,
    };
  }
}

class Teacher {
  final String id;
  final String name;
  final String subject;
  final String teacherClass; // mapped from class
  final bool isClassTeacher;
  String? lastMessage;
  final List<Message> messages;

  Teacher({
    required this.id,
    required this.name,
    required this.subject,
    required this.teacherClass,
    this.isClassTeacher = false,
    this.lastMessage,
    this.messages = const [],
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    var msgsJson = json['messages'] as List<dynamic>?;
    List<Message> msgs = msgsJson != null
        ? msgsJson.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList()
        : [];
    return Teacher(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      teacherClass: json['class'] as String,
      isClassTeacher: json['isClassTeacher'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      messages: msgs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'class': teacherClass,
      'isClassTeacher': isClassTeacher,
      'lastMessage': lastMessage,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}

class NoticeCta {
  final String label;
  final String action;

  NoticeCta({required this.label, required this.action});

  factory NoticeCta.fromJson(Map<String, dynamic> json) {
    return NoticeCta(
      label: json['label'] as String,
      action: json['action'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'action': action,
    };
  }
}

class NoticeAttachment {
  final String name;
  final String url;
  final int sizeBytes;
  final String contentType;

  NoticeAttachment({
    required this.name,
    required this.url,
    this.sizeBytes = 0,
    this.contentType = '',
  });

  factory NoticeAttachment.fromJson(Map<String, dynamic> json) {
    return NoticeAttachment(
      name: (json['name'] ?? json['fileName'] ?? 'Attachment').toString(),
      url: (json['readUrl'] ?? json['url'] ?? '').toString(),
      sizeBytes: (json['sizeBytes'] is int)
          ? json['sizeBytes'] as int
          : int.tryParse(json['sizeBytes']?.toString() ?? '0') ?? 0,
      contentType: (json['contentType'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'sizeBytes': sizeBytes,
      'contentType': contentType,
    };
  }

  String get formattedSize {
    if (sizeBytes <= 0) return '';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class Notice {
  final String id;
  final String source;
  final String title;
  final String date;
  final String time;
  final String body;
  final NoticeCta? cta;
  final String category;
  final String? publishedAt;
  final List<NoticeAttachment> attachments;
  final String? externalUrl;
  final String? externalUrlLabel;
  final bool isRead;

  Notice({
    required this.id,
    required this.source,
    required this.title,
    required this.date,
    required this.time,
    required this.body,
    this.cta,
    this.category = 'School Notice',
    this.publishedAt,
    this.attachments = const [],
    this.externalUrl,
    this.externalUrlLabel,
    this.isRead = false,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    String formattedDate = (json['date'] ?? '').toString();
    String formattedTime = (json['time'] ?? '').toString();
    final pubAt = json['publishedAt']?.toString() ?? json['createdAt']?.toString();

    if (pubAt != null && pubAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(pubAt).toLocal();
        if (formattedDate.isEmpty) {
          formattedDate = DateFormat('d MMM yyyy').format(dt);
        }
        if (formattedTime.isEmpty) {
          formattedTime = DateFormat('hh:mm a').format(dt);
        }
      } catch (_) {}
    }

    if (formattedDate.isEmpty) {
      formattedDate = 'Recent';
    }

    List<NoticeAttachment> parsedAttachments = [];
    if (json['attachments'] is List) {
      for (final a in json['attachments'] as List) {
        if (a is Map<String, dynamic>) {
          parsedAttachments.add(NoticeAttachment.fromJson(a));
        } else if (a is String && a.isNotEmpty) {
          final uriParts = a.split('/');
          final fileName = uriParts.isNotEmpty ? uriParts.last : 'Attachment';
          parsedAttachments.add(NoticeAttachment(name: fileName, url: a));
        }
      }
    }

    return Notice(
      id: (json['id'] ?? '').toString(),
      source: (json['source'] ?? json['senderName'] ?? json['author'] ?? 'School Administration').toString(),
      title: (json['title'] ?? 'Notice').toString(),
      date: formattedDate,
      time: formattedTime,
      body: (json['body'] ?? json['message'] ?? '').toString(),
      cta: json['cta'] != null ? NoticeCta.fromJson(json['cta'] as Map<String, dynamic>) : null,
      category: (json['category'] ?? 'School Notice').toString(),
      publishedAt: pubAt,
      attachments: parsedAttachments,
      externalUrl: json['externalUrl']?.toString(),
      externalUrlLabel: json['externalUrlLabel']?.toString(),
      isRead: json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'title': title,
      'date': date,
      'time': time,
      'body': body,
      'cta': cta?.toJson(),
      'category': category,
      'publishedAt': publishedAt,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'externalUrl': externalUrl,
      'externalUrlLabel': externalUrlLabel,
      'isRead': isRead,
    };
  }

  Notice copyWith({bool? isRead}) {
    return Notice(
      id: id,
      source: source,
      title: title,
      date: date,
      time: time,
      body: body,
      cta: cta,
      category: category,
      publishedAt: publishedAt,
      attachments: attachments,
      externalUrl: externalUrl,
      externalUrlLabel: externalUrlLabel,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ClassUpdate {
  final String id;
  final String type; // 'Classwork' | 'Homework'
  final String subject;
  final String classTarget; // mapped from class
  final String teacher;
  final String body;
  final List<String>? attachments;
  final String date;

  ClassUpdate({
    required this.id,
    required this.type,
    required this.subject,
    required this.classTarget,
    required this.teacher,
    required this.body,
    this.attachments,
    required this.date,
  });

  factory ClassUpdate.fromJson(Map<String, dynamic> json) {
    return ClassUpdate(
      id: json['id'] as String,
      type: json['type'] as String,
      subject: json['subject'] as String,
      classTarget: json['class'] as String,
      teacher: json['teacher'] as String,
      body: json['body'] as String,
      attachments: (json['attachments'] as List<dynamic>?)?.map((e) => e as String).toList(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'subject': subject,
      'class': classTarget,
      'teacher': teacher,
      'body': body,
      'attachments': attachments,
      'date': date,
    };
  }
}

class Event {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;
  final String startDate;
  final String endDate;
  final String? startTime;
  final String? endTime;
  final bool isAllDay;
  final String category; // 'CULTURAL' | 'ACADEMIC' | 'SPORTS' | 'GENERAL'
  final String scope; // 'SCHOOL' | 'CLASS' | 'SECTION'
  final String attendanceImpact;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    this.location = 'School Campus',
    this.description = '',
    this.startDate = '',
    this.endDate = '',
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.category = 'GENERAL',
    this.scope = 'SCHOOL',
    this.attendanceImpact = 'REGULAR_ATTENDANCE',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final start = json['startDate']?.toString() ?? json['date']?.toString() ?? '';
    final end = json['endDate']?.toString() ?? start;
    final isAllDay = json['isAllDay'] as bool? ?? false;
    final sTime = json['startTime']?.toString();
    final eTime = json['endTime']?.toString();

    // Format human-friendly time string
    String formattedTime = json['time']?.toString() ?? '';
    if (formattedTime.isEmpty) {
      if (isAllDay) {
        formattedTime = 'All Day';
      } else if (sTime != null && sTime.isNotEmpty) {
        formattedTime = eTime != null && eTime.isNotEmpty ? '$sTime - $eTime' : sTime;
      } else {
        formattedTime = 'All Day';
      }
    }

    // Format human-friendly date string
    String formattedDate = json['date']?.toString() ?? '';
    if (formattedDate.isEmpty && start.isNotEmpty) {
      try {
        final dt = DateTime.parse(start);
        formattedDate = DateFormat('EEEE, d MMMM yyyy').format(dt);
      } catch (_) {
        formattedDate = start;
      }
    }

    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Event',
      date: formattedDate.isNotEmpty ? formattedDate : 'Upcoming',
      time: formattedTime,
      location: json['location']?.toString() ?? 'School Campus',
      description: json['description']?.toString() ?? '',
      startDate: start,
      endDate: end,
      startTime: sTime,
      endTime: eTime,
      isAllDay: isAllDay,
      category: json['category']?.toString() ?? 'GENERAL',
      scope: json['scope']?.toString() ?? 'SCHOOL',
      attendanceImpact: json['attendanceImpact']?.toString() ?? 'REGULAR_ATTENDANCE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'isAllDay': isAllDay,
      'category': category,
      'scope': scope,
      'attendanceImpact': attendanceImpact,
    };
  }
}

class FeeHistory {
  final String id;
  final double amount;
  final String date;
  final String reference;
  final String method;

  FeeHistory({
    required this.id,
    required this.amount,
    required this.date,
    required this.reference,
    required this.method,
  });

  factory FeeHistory.fromJson(Map<String, dynamic> json) {
    return FeeHistory(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      method: json['method'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date,
      'reference': reference,
      'method': method,
    };
  }
}

class Fee {
  String status; // 'Due' | 'Paid'
  double amount;
  final String? dueDate;
  final List<FeeHistory> history;

  Fee({
    required this.status,
    required this.amount,
    this.dueDate,
    required this.history,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    var histJson = json['history'] as List<dynamic>?;
    List<FeeHistory> hist = histJson != null
        ? histJson.map((e) => FeeHistory.fromJson(e as Map<String, dynamic>)).toList()
        : [];
    return Fee(
      status: json['status'] as String? ?? 'Paid',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] as String?,
      history: hist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'amount': amount,
      'dueDate': dueDate,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}

class Photo {
  final String id;
  final String url;

  Photo({required this.id, required this.url});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}

class Album {
  final String id;
  final String title;
  final String coverPhoto;
  final int? _photoCount;
  final List<Photo> photos;

  Album({
    required this.id,
    required this.title,
    required this.coverPhoto,
    int? photoCount,
    required this.photos,
  }) : _photoCount = photoCount ?? photos.length;

  int get photoCount => _photoCount ?? photos.length;

  factory Album.fromJson(Map<String, dynamic> json) {
    var photosJson = json['photos'] as List<dynamic>?;
    List<Photo> pts = photosJson != null
        ? photosJson.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
        : [];
    return Album(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverPhoto: json['coverPhoto'] as String? ?? '',
      photoCount: (json['photoCount'] as num?)?.toInt() ?? pts.length,
      photos: pts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverPhoto': coverPhoto,
      'photoCount': photoCount,
      'photos': photos.map((e) => e.toJson()).toList(),
    };
  }
}

class Holiday {
  final String id;
  final String date;
  final String day;
  final String month;
  final String title;
  final String type; // 'National' | 'Festival' | 'School'

  Holiday({
    required this.id,
    required this.date,
    required this.day,
    required this.month,
    required this.title,
    required this.type,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] as String,
      date: json['date'] as String,
      day: json['day'] as String,
      month: json['month'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'day': day,
      'month': month,
      'title': title,
      'type': type,
    };
  }
}

class ExamResult {
  final String id;
  final String title;
  final String examClass; // mapped from class
  final String date;
  final String status; // 'Published' | 'Upcoming'

  ExamResult({
    required this.id,
    required this.title,
    required this.examClass,
    required this.date,
    required this.status,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] as String,
      title: json['title'] as String,
      examClass: json['class'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'class': examClass,
      'date': date,
      'status': status,
    };
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String? issueDate;
  final String? dueDate;
  final String? reserveDate;
  String status; // 'Issued' | 'Reserved'

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.issueDate,
    this.dueDate,
    this.reserveDate,
    required this.status,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      issueDate: json['issueDate'] as String?,
      dueDate: json['dueDate'] as String?,
      reserveDate: json['reserveDate'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'issueDate': issueDate,
      'dueDate': dueDate,
      'reserveDate': reserveDate,
      'status': status,
    };
  }
}

class AttendanceCalendarDay {
  final String? _status;
  final String? _reason;
  final String? _notes;
  final DateTime? date;

  AttendanceCalendarDay({
    String? status,
    String? reason,
    String? notes,
    this.date,
  })  : _status = status ?? 'P',
        _reason = reason ?? '',
        _notes = notes ?? '';

  String get status => _status ?? 'P';
  String get reason => _reason ?? '';
  String get notes => _notes ?? '';

  factory AttendanceCalendarDay.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarDay(
      status: json['status'] as String? ?? 'P',
      reason: json['reason'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'reason': reason,
      'notes': notes,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }
}

class AttendanceSummary {
  final int? _present;
  final int? _absent;
  final int? _late;
  final int? _halfDay;
  final int? _holiday;
  final int? _weekend;
  final int? _totalWorkingDays;
  final int? _attendancePercentage;

  AttendanceSummary({
    int? present,
    int? absent,
    int? late,
    int? halfDay,
    int? holiday,
    int? weekend,
    int? totalWorkingDays,
    int? attendancePercentage,
  })  : _present = present ?? 0,
        _absent = absent ?? 0,
        _late = late ?? 0,
        _halfDay = halfDay ?? 0,
        _holiday = holiday ?? 0,
        _weekend = weekend ?? 4,
        _totalWorkingDays = totalWorkingDays ?? ((present ?? 0) + (absent ?? 0) + (late ?? 0) + (halfDay ?? 0)),
        _attendancePercentage = attendancePercentage ?? 100;

  int get present => _present ?? 0;
  int get absent => _absent ?? 0;
  int get late => _late ?? 0;
  int get halfDay => _halfDay ?? 0;
  int get holiday => _holiday ?? 0;
  int get weekend => _weekend ?? 4;
  int get totalWorkingDays =>
      _totalWorkingDays ?? (present + absent + late + halfDay);
  int get attendancePercentage {
    if (_attendancePercentage != null) return _attendancePercentage;
    final total = totalWorkingDays;
    if (total > 0) {
      return (((present + late + halfDay * 0.5) / total) * 100).round();
    }
    return 100;
  }

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    final present = (json['present'] as num?)?.toInt() ?? 0;
    final absent = (json['absent'] as num?)?.toInt() ?? 0;
    final late = (json['late'] as num?)?.toInt() ?? 0;
    final halfDay = (json['halfDay'] as num?)?.toInt() ?? 0;
    final holiday = (json['holiday'] as num?)?.toInt() ?? 0;
    final weekend = (json['weekend'] as num?)?.toInt() ?? 4;
    final totalWorkingDays = (json['totalWorkingDays'] as num?)?.toInt() ?? (present + absent + late + halfDay);
    final percentage = (json['attendancePercentage'] as num?)?.toInt() ?? (
      totalWorkingDays > 0 ? (((present + late + halfDay * 0.5) / totalWorkingDays) * 100).round() : 100
    );

    return AttendanceSummary(
      present: present,
      absent: absent,
      late: late,
      halfDay: halfDay,
      holiday: holiday,
      weekend: weekend,
      totalWorkingDays: totalWorkingDays,
      attendancePercentage: percentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'absent': absent,
      'late': late,
      'halfDay': halfDay,
      'holiday': holiday,
      'weekend': weekend,
      'totalWorkingDays': totalWorkingDays,
      'attendancePercentage': attendancePercentage,
    };
  }
}

class Attendance {
  final String? _month;
  final int? _monthNumber;
  final int? _year;
  final AttendanceSummary? _summary;
  final Map<String, AttendanceCalendarDay>? _calendar;

  Attendance({
    String? month,
    int? monthNumber,
    int? year,
    AttendanceSummary? summary,
    Map<String, AttendanceCalendarDay>? calendar,
  })  : _month = month ?? 'October 2026',
        _monthNumber = monthNumber ?? 10,
        _year = year ?? 2026,
        _summary = summary ??
            AttendanceSummary(
              present: 0,
              absent: 0,
              holiday: 0,
              weekend: 0,
            ),
        _calendar = calendar ?? const {};

  String get month => _month ?? 'October 2026';
  int get monthNumber => _monthNumber ?? DateTime.now().month;
  int get year => _year ?? DateTime.now().year;
  AttendanceSummary get summary =>
      _summary ??
      AttendanceSummary(
        present: 0,
        absent: 0,
        holiday: 0,
        weekend: 0,
      );
  Map<String, AttendanceCalendarDay> get calendar => _calendar ?? {};

  factory Attendance.fromJson(Map<String, dynamic> json) {
    var calRaw = json['calendar'] as Map<String, dynamic>? ?? {};
    Map<String, AttendanceCalendarDay> calMap = {};
    calRaw.forEach((day, data) {
      if (data is Map<String, dynamic>) {
        calMap[day] = AttendanceCalendarDay.fromJson(data);
      }
    });

    return Attendance(
      month: json['month'] as String? ?? 'Current Month',
      monthNumber: (json['monthNumber'] as num?)?.toInt() ?? DateTime.now().month,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      summary: AttendanceSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      calendar: calMap,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> calMap = {};
    calendar.forEach((key, value) {
      calMap[key] = value.toJson();
    });
    return {
      'month': month,
      'monthNumber': monthNumber,
      'year': year,
      'summary': summary.toJson(),
      'calendar': calMap,
    };
  }
}

class SchoolConfig {
  final String name;
  final String nameMarathi;
  final String logo;

  SchoolConfig({
    required this.name,
    required this.nameMarathi,
    required this.logo,
  });
}
