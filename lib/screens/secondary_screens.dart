import 'dart:convert';
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
// 9. Events Screen
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.fetchEvents(appState.currentChild.id);
    if (mounted) setState(() {});
  }

  Color _getCategoryBg(String cat) {
    switch (cat.toUpperCase()) {
      case 'CULTURAL':
        return const Color(0xFFF3E8FF);
      case 'ACADEMIC':
        return const Color(0xFFE0F2FE);
      case 'SPORTS':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFE0F2F1);
    }
  }

  Color _getCategoryText(String cat) {
    switch (cat.toUpperCase()) {
      case 'CULTURAL':
        return const Color(0xFF7E22CE);
      case 'ACADEMIC':
        return const Color(0xFF0369A1);
      case 'SPORTS':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF00695C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allEvents = appState.events;
    final currentChild = appState.currentChild;
    final childAvatar = appState.childAvatars[currentChild.id];
    final isLoading = appState.isEventsLoading;

    // Filter events based on category
    final filteredEvents = _selectedCategory == 'ALL'
        ? allEvents
        : allEvents.where((e) => e.category.toUpperCase() == _selectedCategory).toList();

    const categories = ['ALL', 'CULTURAL', 'ACADEMIC', 'SPORTS', 'GENERAL'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'events'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                  )
                : const Icon(LucideIcons.refreshCw, color: AppColors.textMain, size: 20),
            onPressed: isLoading ? null : _loadEvents,
            tooltip: 'Refresh Events',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        color: AppColors.primaryTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child Badge Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryTeal,
                      ),
                      alignment: Alignment.center,
                      child: childAvatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: Image.memory(
                                base64Decode(childAvatar),
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              currentChild.name.isNotEmpty
                                  ? currentChild.name.substring(0, 1).toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentChild.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          Text(
                            currentChild.grade.isNotEmpty ? currentChild.grade : 'Student',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${allEvents.length} Events',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          cat == 'ALL' ? 'All Events' : cat.substring(0, 1) + cat.substring(1).toLowerCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textMain,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primaryTeal,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryTeal : AppColors.border,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Events List
              if (isLoading && allEvents.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryTeal),
                  ),
                ),
              ] else if (filteredEvents.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.calendar, size: 28, color: AppColors.primaryTeal),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Events Found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedCategory == 'ALL'
                            ? 'There are no upcoming events or celebrations scheduled right now.'
                            : 'No events found under the selected category.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredEvents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final event = filteredEvents[idx];

                    DateTime? parsedDate;
                    if (event.startDate.isNotEmpty) {
                      parsedDate = DateTime.tryParse(event.startDate);
                    }
                    if (parsedDate == null && event.date.isNotEmpty) {
                      parsedDate = DateTime.tryParse(event.date);
                    }

                    final monthLabel = parsedDate != null
                        ? DateFormat('MMM').format(parsedDate).toUpperCase()
                        : 'EVT';
                    final dayLabel = parsedDate != null ? DateFormat('d').format(parsedDate) : '•';
                    final weekDayLabel = parsedDate != null ? DateFormat('EEE').format(parsedDate) : '';

                    final catBg = _getCategoryBg(event.category);
                    final catColor = _getCategoryText(event.category);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/events/detail',
                              arguments: event,
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Badge Box
                                Container(
                                  width: 58,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFBBF7D0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        monthLabel,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF15803D),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dayLabel,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF166534),
                                        ),
                                      ),
                                      if (weekDayLabel.isNotEmpty) ...[
                                        const SizedBox(height: 1),
                                        Text(
                                          weekDayLabel,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Event Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Category & Scope Badges
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: catBg,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              event.category,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: catColor,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                          if (event.scope.isNotEmpty && event.scope != 'SCHOOL')
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                event.scope == 'CLASS' ? 'Class Event' : 'Section Event',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Event Title
                                      Text(
                                        event.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Time Row
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.clock, size: 13, color: AppColors.textMuted),
                                          const SizedBox(width: 5),
                                          Text(
                                            event.time,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),

                                      // Location Row
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.mapPin, size: 13, color: AppColors.textMuted),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              event.location,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 10. Event Detail Screen
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  Color _getCategoryBg(String cat) {
    switch (cat.toUpperCase()) {
      case 'CULTURAL':
        return const Color(0xFFF3E8FF);
      case 'ACADEMIC':
        return const Color(0xFFE0F2FE);
      case 'SPORTS':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFE0F2F1);
    }
  }

  Color _getCategoryText(String cat) {
    switch (cat.toUpperCase()) {
      case 'CULTURAL':
        return const Color(0xFF7E22CE);
      case 'ACADEMIC':
        return const Color(0xFF0369A1);
      case 'SPORTS':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF00695C);
    }
  }

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
    if (event.startDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(event.startDate);
    }
    if (parsedDate == null && event.date.isNotEmpty) {
      parsedDate = DateTime.tryParse(event.date);
    }
    final fullDateStr = parsedDate != null
        ? DateFormat('EEEE, d MMMM yyyy').format(parsedDate)
        : event.date;

    final catBg = _getCategoryBg(event.category);
    final catColor = _getCategoryText(event.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'eventDetails'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.scope == 'SCHOOL'
                              ? 'School Wide'
                              : (event.scope == 'CLASS' ? 'Class Event' : 'Section Event'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      if (event.attendanceImpact == 'NO_ATTENDANCE_REQUIRED')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No Attendance Required',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: LucideIcons.calendar,
                    iconColor: AppColors.primaryTeal,
                    title: 'Date',
                    value: fullDateStr,
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _buildDetailRow(
                    icon: LucideIcons.clock,
                    iconColor: const Color(0xFF0284C7),
                    title: 'Time',
                    value: event.time,
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _buildDetailRow(
                    icon: LucideIcons.mapPin,
                    iconColor: const Color(0xFFE11D48),
                    title: 'Location',
                    value: event.location,
                  ),
                  if (event.attendanceImpact.isNotEmpty) ...[
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailRow(
                      icon: LucideIcons.userCheck,
                      iconColor: const Color(0xFF059669),
                      title: 'Attendance Policy',
                      value: event.attendanceImpact == 'NO_ATTENDANCE_REQUIRED'
                          ? 'Optional / No Attendance Required'
                          : 'Regular Attendance Marked',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            if (event.description.isNotEmpty) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.fileText, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          'description'.tr().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMain,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Events',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ],
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

