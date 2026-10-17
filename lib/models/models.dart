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

class Notice {
  final String id;
  final String source;
  final String title;
  final String date;
  final String time;
  final String body;
  final NoticeCta? cta;

  Notice({
    required this.id,
    required this.source,
    required this.title,
    required this.date,
    required this.time,
    required this.body,
    this.cta,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      source: json['source'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      body: json['body'] as String,
      cta: json['cta'] != null ? NoticeCta.fromJson(json['cta'] as Map<String, dynamic>) : null,
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
    };
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

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
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
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] as String,
      reference: json['reference'] as String,
      method: json['method'] as String,
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
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
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
      id: json['id'] as String,
      url: json['url'] as String,
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
  final int photoCount;
  final List<Photo> photos;

  Album({
    required this.id,
    required this.title,
    required this.coverPhoto,
    required this.photoCount,
    required this.photos,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    var photosJson = json['photos'] as List<dynamic>?;
    List<Photo> pts = photosJson != null
        ? photosJson.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
        : [];
    return Album(
      id: json['id'] as String,
      title: json['title'] as String,
      coverPhoto: json['coverPhoto'] as String,
      photoCount: json['photoCount'] as int,
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
  final String status; // 'P' | 'A' | 'L' | 'HD' | 'H' | 'W'
  final String reason;
  final String notes;
  final DateTime? date;

  AttendanceCalendarDay({
    required this.status,
    required this.reason,
    this.notes = '',
    this.date,
  });

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
  final int present;
  final int absent;
  final int late;
  final int halfDay;
  final int holiday;
  final int weekend;
  final int totalWorkingDays;
  final int attendancePercentage;

  AttendanceSummary({
    required this.present,
    required this.absent,
    this.late = 0,
    this.halfDay = 0,
    required this.holiday,
    required this.weekend,
    this.totalWorkingDays = 0,
    this.attendancePercentage = 100,
  });

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
  final String month;
  final int monthNumber;
  final int year;
  final AttendanceSummary summary;
  final Map<String, AttendanceCalendarDay> calendar;

  Attendance({
    required this.month,
    this.monthNumber = 10,
    this.year = 2026,
    required this.summary,
    required this.calendar,
  });

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
