import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';

// 1. Holidays Screen
class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final list = appState.holidays;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('holidays'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: list.length,
        itemBuilder: (context, idx) {
          final item = list[idx];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.plane, color: AppColors.primaryTeal),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
              subtitle: Text('${item.date} ${item.month} • ${item.day}', style: const TextStyle(color: AppColors.textMuted)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.type,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryOrange),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 2. My Teachers Screen
class MyTeachersScreen extends StatelessWidget {
  const MyTeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final list = appState.teachers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('myTeachers'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: list.length,
        itemBuilder: (context, idx) {
          final item = list[idx];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                child: Text(item.name.split(' ').last.substring(0, 1), style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
              ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
              subtitle: Text('${item.subject} • ${item.teacherClass}', style: const TextStyle(color: AppColors.textMuted)),
              trailing: item.isClassTeacher
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryTeal, borderRadius: BorderRadius.circular(12)),
                      child: Text('classTeacher'.tr(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// 3. Health Records Screen
class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('healthRecords'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.heartPulse, color: AppColors.error, size: 28),
                  const SizedBox(width: 12),
                  Text('studentHealthReport'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('bloodGroup'.tr(), 'O+'),
              const Divider(color: AppColors.border, height: 24),
              _buildInfoRow('height'.tr(), '134 cm'),
              const Divider(color: AppColors.border, height: 24),
              _buildInfoRow('weight'.tr(), '28 kg'),
              const Divider(color: AppColors.border, height: 24),
              _buildInfoRow('medicalConditions'.tr(), 'none'.tr()),
              const Divider(color: AppColors.border, height: 24),
              _buildInfoRow('vaccinationStatus'.tr(), 'fullyVaccinated'.tr()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 4. Library Screen
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final list = appState.books;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('library'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: list.isEmpty
          ? Center(child: Text('noBooksIssued'.tr(), style: const TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final item = list[idx];
                final isIssued = item.status == 'Issued';
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textMain)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isIssued ? AppColors.primaryTeal.withValues(alpha: 0.1) : AppColors.secondaryOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isIssued ? 'issued'.tr() : 'reserved'.tr(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isIssued ? AppColors.primaryTeal : AppColors.secondaryOrange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(item.author, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        const SizedBox(height: 12),
                        if (isIssued) ...[
                          Text('${'issueDate'.tr()}: ${item.issueDate}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          Text('${'dueDate'.tr()}: ${item.dueDate}', style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
                        ] else ...[
                          Text('${'reserveDate'.tr()}: ${item.reserveDate}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// 5. Bus Tracking Screen
class BusTrackingScreen extends StatelessWidget {
  const BusTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('busTracking'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.bus, color: AppColors.primaryTeal, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${'routeNo'.tr()} 12', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          Text('${'driverName'.tr()}: Mr. Santosh Shinde', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('currentLocation'.tr(), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text('nearSiddhiTemple'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('eta'.tr(), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text('10 ${'minutes'.tr()}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Mock map placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.mapPin, color: AppColors.primaryTeal, size: 48),
                    const SizedBox(height: 12),
                    Text('mapViewerPlaceholder'.tr(), style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. Gallery Screen
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final albums = appState.albums;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('gallery'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: albums.length,
        itemBuilder: (context, idx) {
          final album = albums[idx];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                // Navigate to detail view
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlbumDetailScreen(album: album)),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.image, size: 48, color: AppColors.primaryTeal),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(album.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                        Text('${album.photoCount} ${'photos'.tr()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(album.title, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: album.photos.length,
        itemBuilder: (context, idx) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(LucideIcons.image, color: AppColors.primaryTeal, size: 24),
          );
        },
      ),
    );
  }
}

// 7. Exam Results Screen
class ExamResultsScreen extends StatelessWidget {
  const ExamResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('examResults'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.award, color: AppColors.primaryTeal, size: 64),
            const SizedBox(height: 16),
            Text('noResultsReleased'.tr(), style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// 8. Exam Details Screen
class ExamDetailsScreen extends StatelessWidget {
  const ExamDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('examDetails'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.fileText, color: AppColors.secondaryOrange, size: 64),
            const SizedBox(height: 16),
            Text('noUpcomingExams'.tr(), style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// 9. Events Screen
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final eventsList = appState.events;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('events'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: eventsList.isEmpty
          ? Center(child: Text('noEvents'.tr(), style: const TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: eventsList.length,
              itemBuilder: (context, idx) {
                final event = eventsList[idx];
                DateTime? parsedDate;
                try {
                  parsedDate = DateTime.parse(event.date);
                } catch (_) {}
                final dateStr = parsedDate != null
                    ? DateFormat.yMMMd().format(parsedDate)
                    : event.date;

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/events/detail',
                        arguments: event,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(LucideIcons.calendar, color: AppColors.primaryTeal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$dateStr • ${event.time}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  event.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// 10. Event Detail Screen
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as Event?;

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: Text('Event not found')),
      );
    }

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(event.date);
    } catch (_) {}
    final dateStr = parsedDate != null
        ? DateFormat('EEEE, MMMM d, y').format(parsedDate)
        : event.date;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('eventDetails'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 20),
              
              // Metadata fields
              Row(
                children: [
                  const Icon(LucideIcons.calendar, color: AppColors.primaryTeal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.clock, color: AppColors.primaryTeal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.time,
                      style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.mapPin, color: AppColors.primaryTeal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.location,
                      style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: AppColors.border, height: 1),
              ),
              
              Text(
                'description'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 11. Help Screen with Collapsible FAQs
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('help'.tr(), style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Frequently Asked Questions Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'faq'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem('faq_attendance_q'.tr(), 'faq_attendance_a'.tr()),
                  const Divider(color: AppColors.border, height: 1),
                  _buildFaqItem('faq_homework_q'.tr(), 'faq_homework_a'.tr()),
                  const Divider(color: AppColors.border, height: 1),
                  _buildFaqItem('faq_chat_q'.tr(), 'faq_chat_a'.tr()),
                  const Divider(color: AppColors.border, height: 1),
                  _buildFaqItem('faq_fees_q'.tr(), 'faq_fees_a'.tr()),
                  const Divider(color: AppColors.border, height: 1),
                  _buildFaqItem('faq_switcher_q'.tr(), 'faq_switcher_a'.tr()),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Contact Support Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'contactSupport'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(LucideIcons.phone, color: AppColors.primaryTeal),
                    title: const Text('+91 22 1234 5678', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.mail, color: AppColors.primaryTeal),
                    title: const Text('support@veyhoschool.edu.in', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        iconColor: AppColors.textMuted,
        collapsedIconColor: AppColors.textMuted,
        childrenPadding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

