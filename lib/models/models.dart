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
  final String? photoUrl;
  final String? rollNumber;

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
    this.photoUrl,
    this.rollNumber,
  });

  factory Child.empty() {
    return Child(
      id: '',
      name: 'Student',
      grade: '—',
      enrollmentNo: '—',
      dob: '—',
      gender: '—',
      apaarId: '—',
      penNo: '—',
      studentId: '',
      photoUrl: null,
      rollNumber: null,
    );
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Student').toString(),
      grade: (json['grade'] ?? '—').toString(),
      enrollmentNo: (json['enrollmentNo'] ?? '—').toString(),
      dob: (json['dob'] ?? '—').toString(),
      gender: (json['gender'] ?? '—').toString(),
      apaarId: (json['apaarId'] ?? '—').toString(),
      penNo: (json['penNo'] ?? '—').toString(),
      studentId: (json['studentId'] ?? '').toString(),
      photoUrl: json['photoUrl'] as String?,
      rollNumber: json['rollNumber'] as String?,
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
      'photoUrl': photoUrl,
      'rollNumber': rollNumber,
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
  final List<String> subjects;
  final String teacherClass; // mapped from class
  final bool isClassTeacher;
  String? lastMessage;
  final List<Message> messages;

  Teacher({
    required this.id,
    required this.name,
    required this.subject,
    this.subjects = const [],
    required this.teacherClass,
    this.isClassTeacher = false,
    this.lastMessage,
    this.messages = const [],
  });

  String get displaySubjects {
    if (subjects.isNotEmpty) {
      return subjects.join(', ');
    }
    if (subject.isNotEmpty && subject != 'Subject' && subject != 'Class Teacher') {
      return subject;
    }
    if (isClassTeacher) {
      return 'Class Teacher';
    }
    return 'Subject Teacher';
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    var msgsJson = json['messages'] as List<dynamic>?;
    List<Message> msgs = msgsJson != null
        ? msgsJson.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList()
        : [];
    List<String> subs = [];
    if (json['subjects'] != null) {
      subs = (json['subjects'] as List<dynamic>).map((e) => e.toString()).toList();
    } else if (json['subject'] != null && json['subject'].toString().isNotEmpty) {
      subs = [json['subject'].toString()];
    }

    return Teacher(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      subject: subs.isNotEmpty ? subs.join(', ') : (json['subject'] as String? ?? ''),
      subjects: subs,
      teacherClass: (json['class'] ?? json['teacherClass'] ?? '').toString(),
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
      'subjects': subjects,
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

  bool get isMedia {
    final n = name.toLowerCase();
    final c = contentType.toLowerCase();
    return c.startsWith('image/') ||
        c.startsWith('video/') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png') ||
        n.endsWith('.webp') ||
        n.endsWith('.gif') ||
        n.endsWith('.mp4') ||
        n.endsWith('.mov') ||
        n.endsWith('.webm');
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
  final String broadcastType;
  final String? publishedAt;
  final List<NoticeAttachment> attachments;
  final String? externalUrl;
  final String? externalUrlLabel;
  final String? eventId;
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
    this.broadcastType = 'school_notice',
    this.publishedAt,
    this.attachments = const [],
    this.externalUrl,
    this.externalUrlLabel,
    this.eventId,
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

    String cat = (json['category'] ?? 'School Notice').toString();
    if (cat.toLowerCase().contains('grade') ||
        cat.toLowerCase().contains('section') ||
        cat.toLowerCase().contains('class') ||
        cat.toLowerCase().contains('student')) {
      cat = 'Class Notice';
    } else {
      cat = 'School Notice';
    }

    final rawType = json['broadcastType']?.toString();
    String broadcastType = rawType ?? '';
    if (broadcastType.isEmpty) {
      broadcastType = cat.contains('Class') ? 'class_notice' : 'school_notice';
    } else if (cat == 'Class Notice') {
      broadcastType = 'class_notice';
    }

    return Notice(
      id: (json['id'] ?? '').toString(),
      source: (json['source'] ?? json['senderName'] ?? json['author'] ?? 'School Administration').toString(),
      title: (json['title'] ?? 'Notice').toString(),
      date: formattedDate,
      time: formattedTime,
      body: (json['body'] ?? json['message'] ?? '').toString(),
      cta: json['cta'] != null ? NoticeCta.fromJson(json['cta'] as Map<String, dynamic>) : null,
      category: cat,
      broadcastType: broadcastType,
      publishedAt: pubAt,
      attachments: parsedAttachments,
      externalUrl: json['externalUrl']?.toString(),
      externalUrlLabel: json['externalUrlLabel']?.toString(),
      eventId: json['eventId']?.toString(),
      isRead: json['isRead'] == true,
    );
  }

  bool get isClassNotice => broadcastType == 'class_notice' || category.toLowerCase().contains('class');
  bool get isSchoolNotice => !isClassNotice;
  bool get isHomework => broadcastType == 'homework';
  bool get isClasswork => broadcastType == 'classwork';

  bool get isGalleryNotice =>
      (eventId != null && eventId!.isNotEmpty) ||
      (externalUrl != null &&
          (externalUrl!.startsWith('veyho://gallery') ||
              externalUrl!.contains('/gallery') ||
              (externalUrlLabel?.toLowerCase().contains('gallery') ?? false)));

  List<NoticeAttachment> get nonMediaAttachments => attachments.where((a) => !a.isMedia).toList();
  List<NoticeAttachment> get displayAttachments => isGalleryNotice ? nonMediaAttachments : attachments;

  DateTime get dateTime {
    if (publishedAt != null && publishedAt!.isNotEmpty) {
      try {
        return DateTime.parse(publishedAt!).toLocal();
      } catch (_) {}
    }
    if (date.isNotEmpty && date != 'Recent') {
      try {
        return DateTime.parse(date);
      } catch (_) {}
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
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
      'broadcastType': broadcastType,
      'publishedAt': publishedAt,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'externalUrl': externalUrl,
      'externalUrlLabel': externalUrlLabel,
      'eventId': eventId,
      'isRead': isRead,
    };
  }

  Notice copyWith({bool? isRead, String? broadcastType, String? eventId}) {
    return Notice(
      id: id,
      source: source,
      title: title,
      date: date,
      time: time,
      body: body,
      cta: cta,
      category: category,
      broadcastType: broadcastType ?? this.broadcastType,
      publishedAt: publishedAt,
      attachments: attachments,
      externalUrl: externalUrl,
      externalUrlLabel: externalUrlLabel,
      eventId: eventId ?? this.eventId,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ClassUpdate {
  final String id;
  final String type; // 'Classwork' | 'Homework'
  final String broadcastType; // 'homework' | 'classwork'
  final String subject;
  final String title;
  final String classTarget; // mapped from class
  final String teacher;
  final String body;
  final List<String> attachments;
  final String date;
  final String time;
  final String? publishedAt;
  final bool isRead;

  ClassUpdate({
    required this.id,
    required this.type,
    this.broadcastType = 'homework',
    required this.subject,
    this.title = '',
    required this.classTarget,
    required this.teacher,
    required this.body,
    this.attachments = const [],
    required this.date,
    this.time = '',
    this.publishedAt,
    this.isRead = false,
  });

  bool get isHomework => type.toLowerCase() == 'homework' || broadcastType == 'homework';
  bool get isClasswork => !isHomework;

  DateTime get dateTime {
    if (publishedAt != null && publishedAt!.isNotEmpty) {
      try {
        return DateTime.parse(publishedAt!).toLocal();
      } catch (_) {}
    }
    if (date.isNotEmpty) {
      try {
        return DateTime.parse(date);
      } catch (_) {}
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory ClassUpdate.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? (json['broadcastType'] == 'classwork' ? 'Classwork' : 'Homework')).toString();
    final bType = (json['broadcastType'] ?? (rawType.toLowerCase() == 'classwork' ? 'classwork' : 'homework')).toString();

    List<String> parsedAttachments = [];
    if (json['attachments'] is List) {
      for (final a in json['attachments'] as List) {
        if (a is String && a.isNotEmpty) {
          parsedAttachments.add(a);
        } else if (a is Map<String, dynamic>) {
          final url = (a['readUrl'] ?? a['url'] ?? '').toString();
          if (url.isNotEmpty) parsedAttachments.add(url);
        }
      }
    }

    return ClassUpdate(
      id: (json['id'] ?? '').toString(),
      type: rawType,
      broadcastType: bType,
      subject: (json['subject'] ?? 'General').toString(),
      title: (json['title'] ?? '').toString(),
      classTarget: (json['class'] ?? json['classTarget'] ?? '').toString(),
      teacher: (json['teacher'] ?? json['senderName'] ?? 'Class Teacher').toString(),
      body: (json['body'] ?? json['description'] ?? '').toString(),
      attachments: parsedAttachments,
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      publishedAt: json['publishedAt']?.toString() ?? json['createdAt']?.toString(),
      isRead: json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'broadcastType': broadcastType,
      'subject': subject,
      'title': title,
      'class': classTarget,
      'teacher': teacher,
      'body': body,
      'attachments': attachments,
      'date': date,
      'time': time,
      'publishedAt': publishedAt,
      'isRead': isRead,
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
  final String url; // Full-resolution SAS URL
  final String thumbnailUrl; // Lightweight web thumbnail SAS URL
  final String name;
  final String type; // 'image' | 'video'
  final String caption;

  Photo({
    required this.id,
    required this.url,
    String? thumbnailUrl,
    this.name = '',
    this.type = 'image',
    this.caption = '',
  }) : thumbnailUrl = (thumbnailUrl != null && thumbnailUrl.isNotEmpty) ? thumbnailUrl : url;

  bool get isVideo => type.toLowerCase() == 'video';

  factory Photo.fromJson(Map<String, dynamic> json) {
    final fullUrl = json['url'] as String? ?? '';
    final thumb = json['thumbnailUrl'] as String? ?? fullUrl;
    return Photo(
      id: json['id'] as String? ?? '',
      url: fullUrl,
      thumbnailUrl: thumb,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
      caption: json['caption'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'name': name,
      'type': type,
      'caption': caption,
    };
  }
}

class Album {
  final String id;
  final String eventId;
  final String title;
  final String category;
  final String eventDate;
  final String location;
  final String coverPhoto;
  final int? _photoCount;
  final List<Photo> photos;

  Album({
    required this.id,
    String? eventId,
    required this.title,
    this.category = 'general',
    this.eventDate = '',
    this.location = '',
    required this.coverPhoto,
    int? photoCount,
    required this.photos,
  })  : eventId = eventId ?? id,
        _photoCount = photoCount ?? photos.length;

  int get photoCount => _photoCount ?? photos.length;

  factory Album.fromJson(Map<String, dynamic> json) {
    final mediaRaw = json['media'] ?? json['photos'];
    var photosJson = mediaRaw as List<dynamic>?;
    List<Photo> pts = photosJson != null
        ? photosJson.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList()
        : [];
    return Album(
      id: json['id'] as String? ?? json['eventId'] as String? ?? '',
      eventId: json['eventId'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      eventDate: json['eventDate'] as String? ?? '',
      location: json['location'] as String? ?? '',
      coverPhoto: json['coverPhoto'] as String? ?? (pts.isNotEmpty ? pts.first.thumbnailUrl : ''),
      photoCount: (json['mediaCount'] as num?)?.toInt() ?? (json['photoCount'] as num?)?.toInt() ?? pts.length,
      photos: pts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'category': category,
      'eventDate': eventDate,
      'location': location,
      'coverPhoto': coverPhoto,
      'photoCount': photoCount,
      'photos': photos.map((e) => e.toJson()).toList(),
    };
  }
}

class AcademicYearItem {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  AcademicYearItem({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  factory AcademicYearItem.fromJson(Map<String, dynamic> json) {
    return AcademicYearItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      isCurrent: json['isCurrent'] == true,
    );
  }

  String get formattedDuration {
    final startFmt = DateFormat('MMM yyyy').format(startDate);
    final endFmt = DateFormat('MMM yyyy').format(endDate);
    return '$startFmt – $endFmt';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCurrent': isCurrent,
    };
  }
}

class Holiday {
  final String id;
  final String date;
  final String day;
  final String month;
  final String title;
  final String type; // 'National' | 'Festival' | 'Gazetted' | 'Bank Holiday' | 'School'
  final String academicYearId;
  final String? description;
  final DateTime fullDate;

  Holiday({
    required this.id,
    required this.date,
    required this.day,
    required this.month,
    required this.title,
    required this.type,
    this.academicYearId = '',
    this.description,
    DateTime? fullDate,
  }) : fullDate = fullDate ?? DateTime.tryParse(date) ?? DateTime.now();

  factory Holiday.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['date'] ?? '').toString();
    DateTime parsedDt;
    if (rawDate.contains('-')) {
      parsedDt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDt = DateTime.now();
    }

    final dayName = json['day']?.toString() ?? DateFormat('EEEE').format(parsedDt);
    final monthShort = json['month']?.toString() ?? DateFormat('MMM').format(parsedDt);
    final dayNum = rawDate.contains('-')
        ? DateFormat('dd').format(parsedDt)
        : (json['date']?.toString() ?? '01');

    return Holiday(
      id: (json['id'] ?? '').toString(),
      date: dayNum,
      day: dayName,
      month: monthShort,
      title: (json['name'] ?? json['title'] ?? '').toString(),
      type: (json['type'] ?? 'School').toString(),
      academicYearId: (json['academicYearId'] ?? '').toString(),
      description: json['description']?.toString(),
      fullDate: parsedDt,
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
      'academicYearId': academicYearId,
      'description': description,
      'fullDate': fullDate.toIso8601String(),
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

class HealthRecord {
  final String studentId;
  final String fullName;
  final String bloodGroup;
  final String allergies;
  final String chronicConditions;
  final String ongoingMedications;
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;
  final String doctorName;
  final String doctorPhone;
  final String notes;

  HealthRecord({
    required this.studentId,
    this.fullName = '',
    this.bloodGroup = 'NA',
    this.allergies = 'NA',
    this.chronicConditions = 'NA',
    this.ongoingMedications = 'NA',
    this.emergencyContactName = 'NA',
    this.emergencyContactRelation = 'NA',
    this.emergencyContactPhone = 'NA',
    this.doctorName = 'NA',
    this.doctorPhone = 'NA',
    this.notes = 'NA',
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    String sanitize(dynamic val) {
      if (val == null) return 'NA';
      final s = val.toString().trim();
      if (s.isEmpty ||
          s == '—' ||
          s.toLowerCase() == 'none reported' ||
          s.toLowerCase() == 'not provided' ||
          s.toLowerCase() == 'n/a') {
        return 'NA';
      }
      return s;
    }

    return HealthRecord(
      studentId: (json['studentId'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      bloodGroup: sanitize(json['bloodGroup']),
      allergies: sanitize(json['allergies']),
      chronicConditions: sanitize(json['chronicConditions'] ?? json['medicalConditions']),
      ongoingMedications: sanitize(json['ongoingMedications']),
      emergencyContactName: sanitize(json['emergencyContactName']),
      emergencyContactRelation: sanitize(json['emergencyContactRelation']),
      emergencyContactPhone: sanitize(json['emergencyContactPhone']),
      doctorName: sanitize(json['doctorName']),
      doctorPhone: sanitize(json['doctorPhone']),
      notes: sanitize(json['notes']),
    );
  }

  factory HealthRecord.empty(String studentId) {
    return HealthRecord(studentId: studentId);
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'ongoingMedications': ongoingMedications,
      'emergencyContactName': emergencyContactName,
      'emergencyContactRelation': emergencyContactRelation,
      'emergencyContactPhone': emergencyContactPhone,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'notes': notes,
    };
  }
}

