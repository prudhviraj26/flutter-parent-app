import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';
import '../widgets/coming_soon_placeholder.dart';
import '../services/gallery_local_store.dart';
export 'health_records_screen.dart';
export 'holidays_screen.dart';

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
                child: Text(
                  item.name.trim().isNotEmpty
                      ? item.name.trim().split(' ').last[0].toUpperCase()
                      : 'T',
                  style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
              subtitle: Text('${item.displaySubjects} • ${item.teacherClass}', style: const TextStyle(color: AppColors.textMuted)),
              trailing: item.isClassTeacher
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF1F4E78), borderRadius: BorderRadius.circular(12)),
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

// 3. Health Records Screen is now fully implemented in lib/screens/health_records_screen.dart

// 4. Library Screen
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'library'.tr(),
      icon: LucideIcons.book,
      featureName: 'Digital Library Portal',
      description: 'The school library catalog is being digitized. You will soon be able to browse available books, track renewal due dates, and reserve reading materials directly from the app.',
      badgeText: 'Coming Soon',
    );
  }
}

// 5. Bus Tracking Screen
class BusTrackingScreen extends StatelessWidget {
  const BusTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'busTracking'.tr(),
      icon: LucideIcons.bus,
      featureName: 'Real-Time Bus Tracking',
      description: 'We are actively integrating real-time GPS hardware with school transport. Soon, you will be able to track your child\'s bus location, route stops, and arrival times live.',
      badgeText: 'In Development',
    );
  }
}

// 6. Gallery Screen
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedCategory = 'ALL';

  static const List<String> _categories = [
    'ALL',
    'SPORTS',
    'CULTURAL',
    'ACADEMIC',
    'CELEBRATION',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGallery();
    });
  }

  Future<void> _loadGallery() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.fetchGallery(appState.currentChild.id);
  }

  Color _getCategoryBg(String cat) {
    switch (cat.toUpperCase()) {
      case 'CULTURAL':
        return const Color(0xFFF3E8FF);
      case 'ACADEMIC':
        return const Color(0xFFE0F2FE);
      case 'SPORTS':
        return const Color(0xFFDCFCE7);
      case 'CELEBRATION':
        return const Color(0xFFFEF3C7);
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
      case 'CELEBRATION':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF00695C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allAlbums = appState.albums;
    final currentChild = appState.currentChild;
    final childAvatar = appState.childAvatars[currentChild.id];
    final isLoading = appState.isGalleryLoading;

    final filteredAlbums = _selectedCategory == 'ALL'
        ? allAlbums
        : allAlbums.where((a) => a.category.toUpperCase() == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'gallery'.tr(),
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
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
      body: RefreshIndicator(
        onRefresh: _loadGallery,
        color: AppColors.primaryTeal,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Student Context Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryTeal,
                      ),
                      alignment: Alignment.center,
                      child: childAvatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.memory(
                                base64Decode(childAvatar),
                                width: 36,
                                height: 36,
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
                                fontSize: 15,
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
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          Text(
                            currentChild.grade.isNotEmpty ? currentChild.grade : 'Student',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Text(
                        '${allAlbums.length} Albums',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Filter Chips
            SliverToBoxAdapter(
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat;
                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1565D8) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1565D8) : const Color(0xFFD0D5DD),
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x331565D8),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          cat == 'ALL' ? 'All' : cat[0] + cat.substring(1).toLowerCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF475467),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Albums List / Empty State / Loader
            if (isLoading && allAlbums.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1565D8),
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (filteredAlbums.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(LucideIcons.image, size: 30, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Event Albums Available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'When school teachers or coordinators share photos and videos from events, they will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = filteredAlbums[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEAECF0)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AlbumDetailScreen(album: album),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover Photo Stack
                              Stack(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: album.coverPhoto.isNotEmpty
                                        ? VeyhoCachedImage(
                                            mediaId: '${album.id}_cover',
                                            url: album.coverPhoto,
                                            eventDate: album.eventDate,
                                            isThumbnail: true,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 180,
                                            color: const Color(0xFFF1F5F9),
                                            child: const Icon(
                                              LucideIcons.image,
                                              size: 38,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                  ),
                                  // Gradient Overlay
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0x59000000),
                                            Colors.transparent,
                                            Color(0xBF000000),
                                          ],
                                          stops: [0.0, 0.45, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Category Pill
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getCategoryBg(album.category),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        album.category.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: _getCategoryText(album.category),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Photo Count Badge
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xA6000000),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.camera, size: 12, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${album.photoCount}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Event Title & Date at Bottom of Cover
                                  Positioned(
                                    bottom: 12,
                                    left: 14,
                                    right: 14,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (album.eventDate.isNotEmpty)
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.calendar, size: 12, color: Color(0xFFE2E8F0)),
                                              const SizedBox(width: 5),
                                              Text(
                                                album.eventDate,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFE2E8F0),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 3),
                                        Text(
                                          album.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Sub-bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (album.location.isNotEmpty)
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF64748B)),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                album.location,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const Text(
                                        'School Event Album',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    Row(
                                      children: const [
                                        Text(
                                          'View Album',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1565D8),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(LucideIcons.arrowRight, size: 14, color: Color(0xFF1565D8)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredAlbums.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 6.1 Album Detail Screen (Photo & Video Grid)
class AlbumDetailScreen extends StatelessWidget {
  final Album? album;

  const AlbumDetailScreen({super.key, this.album});

  @override
  Widget build(BuildContext context) {
    final effectiveAlbum = album ?? (ModalRoute.of(context)!.settings.arguments as Album?);

    if (effectiveAlbum == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Gallery')),
        body: const Center(child: Text('Album not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              effectiveAlbum.title,
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${effectiveAlbum.photos.length} items',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
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
      body: effectiveAlbum.photos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.camera, size: 28, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Photos In This Album',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The school will upload event photos and highlights shortly.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(3),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemCount: effectiveAlbum.photos.length,
              itemBuilder: (context, index) {
                final photo = effectiveAlbum.photos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          photos: effectiveAlbum.photos,
                          initialIndex: index,
                          albumTitle: effectiveAlbum.title,
                          eventDate: effectiveAlbum.eventDate,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VeyhoCachedImage(
                        mediaId: photo.id,
                        url: photo.thumbnailUrl,
                        eventDate: effectiveAlbum.eventDate,
                        isThumbnail: true,
                        fit: BoxFit.cover,
                      ),
                      if (photo.isVideo)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// 6.2 Full Screen Pinch-To-Zoom Image Viewer
class FullScreenImageViewer extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;
  final String albumTitle;
  final String? eventDate;

  const FullScreenImageViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.albumTitle,
    this.eventDate,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Pinch-to-zoom interactive PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (idx) {
              setState(() => _currentIndex = idx);
            },
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: VeyhoCachedImage(
                    mediaId: photo.id,
                    url: photo.url,
                    eventDate: widget.eventDate,
                    isThumbnail: false,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 12,
                left: 12,
                right: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.albumTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_currentIndex + 1} of ${widget.photos.length}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Caption Bar
          if (widget.photos[_currentIndex].caption.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  top: 16,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Text(
                  widget.photos[_currentIndex].caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 7. Exam Results Screen
class ExamResultsScreen extends StatelessWidget {
  const ExamResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'examResults'.tr(),
      icon: LucideIcons.award,
      featureName: 'Report Cards & Exam Results',
      description: 'Term examination mark sheets, progress evaluations, and official digital report cards will be published here as soon as they are finalized by teachers.',
      badgeText: 'Coming Soon',
    );
  }
}

// 8. Exam Details Screen
class ExamDetailsScreen extends StatelessWidget {
  const ExamDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'examDetails'.tr(),
      icon: LucideIcons.fileText,
      featureName: 'Exam Schedules & Timetables',
      description: 'Upcoming unit tests, mid-term timetables, syllabus portions, and seating arrangements will be available here prior to examination dates.',
      badgeText: 'Coming Soon',
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
  bool? _isPastEventsExpanded;

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

  DateTime? _parseEventDate(Event event) {
    if (event.startDate.isNotEmpty) {
      final parsed = DateTime.tryParse(event.startDate);
      if (parsed != null) return parsed;
    }
    if (event.date.isNotEmpty) {
      final parsed = DateTime.tryParse(event.date);
      if (parsed != null) return parsed;
    }
    return null;
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    bool isCollapsible = false,
    bool isExpanded = true,
    VoidCallback? onToggle,
  }) {
    final content = Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        if (isCollapsible) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpanded ? 'Hide' : 'Show',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 13,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ],
    );

    if (isCollapsible && onToggle != null) {
      return InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildEventCard(BuildContext context, Event event, {required bool isPast}) {
    final parsedDate = _parseEventDate(event);

    final monthLabel = parsedDate != null
        ? DateFormat('MMM').format(parsedDate).toUpperCase()
        : 'EVT';
    final dayLabel = parsedDate != null ? DateFormat('d').format(parsedDate) : '•';
    final weekDayLabel = parsedDate != null ? DateFormat('EEE').format(parsedDate) : '';

    final catBg = _getCategoryBg(event.category);
    final catColor = _getCategoryText(event.category);

    return Container(
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPast ? const Color(0xFFE2E8F0) : AppColors.border,
          width: 1,
        ),
        boxShadow: isPast
            ? const [
                BoxShadow(
                  color: Color(0x04000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                )
              ]
            : const [
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
                // Date Badge Box (Vibrant green for Upcoming, Muted Slate for Past)
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isPast ? const Color(0xFFF1F5F9) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPast ? const Color(0xFFE2E8F0) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        monthLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isPast ? const Color(0xFF64748B) : const Color(0xFF15803D),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isPast ? const Color(0xFF334155) : const Color(0xFF166534),
                        ),
                      ),
                      if (weekDayLabel.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          weekDayLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPast ? const Color(0xFF94A3B8) : const Color(0xFF15803D),
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
                      // Category, Scope & Completed Badges
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPast ? const Color(0xFFF1F5F9) : catBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isPast ? const Color(0xFF64748B) : catColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (isPast)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'COMPLETED',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.4,
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isPast ? const Color(0xFF334155) : AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Time Row
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 13,
                            color: isPast ? const Color(0xFF94A3B8) : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            event.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: isPast ? const Color(0xFF94A3B8) : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Location Row
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 13,
                            color: isPast ? const Color(0xFF94A3B8) : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: isPast ? const Color(0xFF94A3B8) : AppColors.textMuted,
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

                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isPast ? const Color(0xFFCBD5E1) : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    // Split events into Upcoming (>= today, sorted ascending) and Past (< today, sorted descending)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Active academic year hard restriction
    AcademicYearItem? currentYear;
    try {
      currentYear = appState.academicYears.firstWhere(
        (y) => y.isCurrent,
        orElse: () => appState.academicYears.isNotEmpty ? appState.academicYears.first : null as dynamic,
      );
    } catch (_) {}
    final currentYearStart = currentYear?.startDate;

    final upcomingEvents = filteredEvents.where((e) {
      final dt = _parseEventDate(e);
      return dt != null && !dt.isBefore(today);
    }).toList();

    // Past Events: Hard restricted to current active academic year only
    final pastEvents = filteredEvents.where((e) {
      final dt = _parseEventDate(e);
      if (dt == null) return false;
      final isPast = dt.isBefore(today);
      final isWithinCurrentSession = currentYearStart == null || !dt.isBefore(currentYearStart);
      return isPast && isWithinCurrentSession;
    }).toList();

    // Sort upcoming ascending (nearest first)
    upcomingEvents.sort((a, b) {
      final dtA = _parseEventDate(a) ?? DateTime(2099);
      final dtB = _parseEventDate(b) ?? DateTime(2099);
      return dtA.compareTo(dtB);
    });

    // Sort past descending (most recent first)
    pastEvents.sort((a, b) {
      final dtA = _parseEventDate(a) ?? DateTime(1970);
      final dtB = _parseEventDate(b) ?? DateTime(1970);
      return dtB.compareTo(dtA);
    });

    // Option C (Smart Dynamic Toggle):
    // If upcoming events exist, default to collapsed (false).
    // If no upcoming events exist, default to expanded (true) so screen isn't empty.
    final bool isPastExpanded = _isPastEventsExpanded ?? upcomingEvents.isEmpty;

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
                // --- SECTION 1: UPCOMING EVENTS ---
                _buildSectionHeader(
                  title: 'UPCOMING EVENTS',
                  count: upcomingEvents.length,
                  icon: LucideIcons.calendarClock,
                  color: const Color(0xFF0D9488),
                ),
                const SizedBox(height: 10),
                if (upcomingEvents.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingEvents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) => _buildEventCard(context, upcomingEvents[idx], isPast: false),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCCFBF1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.calendarCheck2, size: 20, color: Color(0xFF0D9488)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Upcoming Events',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'No planned events at the moment. Check back soon!',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF115E59),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // --- SECTION 2: PAST EVENTS ---
                if (pastEvents.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'PAST EVENTS',
                    count: pastEvents.length,
                    icon: LucideIcons.history,
                    color: const Color(0xFF64748B),
                    isCollapsible: true,
                    isExpanded: isPastExpanded,
                    onToggle: () {
                      setState(() {
                        _isPastEventsExpanded = !isPastExpanded;
                      });
                    },
                  ),
                  if (isPastExpanded) ...[
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pastEvents.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) => _buildEventCard(context, pastEvents[idx], isPast: true),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
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

    final appState = Provider.of<AppState>(context);
    final matchingAlbum = appState.albums.firstWhere(
      (a) => a.eventId == event.id || a.id == event.id,
      orElse: () => Album(id: '', title: '', coverPhoto: '', photos: []),
    );

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

            // Media / Photos Banner if school shared event photos
            if (matchingAlbum.photos.isNotEmpty) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF091B63), Color(0xFF1565D8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x241565D8),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: VeyhoCachedImage(
                          mediaId: '${matchingAlbum.id}_cover',
                          url: matchingAlbum.coverPhoto,
                          eventDate: matchingAlbum.eventDate,
                          isThumbnail: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Event Photos & Highlights',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${matchingAlbum.photoCount} photos shared by school',
                            style: const TextStyle(
                              color: Color(0xFFBAE6FD),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumDetailScreen(album: matchingAlbum),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1565D8),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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

