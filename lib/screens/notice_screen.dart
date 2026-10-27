import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';
import 'secondary_screens.dart';

enum NoticeFilterType {
  all,
  unread,
  school,
  classNotice,
}

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  String _searchTerm = '';
  NoticeFilterType _selectedFilter = NoticeFilterType.all;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.fetchNotices(appState.currentChild.id);
    });
  }

  Future<void> _loadNotices() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.fetchNotices(appState.currentChild.id);
  }

  String _getFilterLabel(NoticeFilterType filter) {
    switch (filter) {
      case NoticeFilterType.all:
        return 'allNotices'.tr();
      case NoticeFilterType.unread:
        return 'Unread';
      case NoticeFilterType.school:
        return 'schoolNotice'.tr();
      case NoticeFilterType.classNotice:
        return 'classNotice'.tr();
    }
  }

  IconData _getFilterIcon(NoticeFilterType filter) {
    switch (filter) {
      case NoticeFilterType.all:
        return LucideIcons.layers;
      case NoticeFilterType.unread:
        return LucideIcons.sparkles;
      case NoticeFilterType.school:
        return LucideIcons.megaphone;
      case NoticeFilterType.classNotice:
        return LucideIcons.users;
    }
  }

  String _formatNoticeSubtitle(Notice notice) {
    final catName = notice.isSchoolNotice ? 'schoolNotice'.tr() : 'classNotice'.tr();
    String timeOrDate = '';
    final dt = notice.dateTime;
    if (dt.millisecondsSinceEpoch > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final noticeDay = DateTime(dt.year, dt.month, dt.day);
      final diffDays = today.difference(noticeDay).inDays;

      if (diffDays == 0) {
        timeOrDate = notice.time.isNotEmpty ? notice.time : DateFormat('hh:mm a').format(dt);
      } else if (diffDays == 1) {
        timeOrDate = 'Yesterday';
      } else {
        timeOrDate = DateFormat('d MMM').format(dt);
      }
    } else {
      timeOrDate = notice.time.isNotEmpty ? notice.time : notice.date;
    }
    return '$catName • $timeOrDate';
  }

  Widget _buildFilterChips(List<Notice> allNotices, AppState appState) {
    final unreadCount = allNotices.where((n) => !appState.isNoticeRead(n.id)).length;
    final schoolUnread = allNotices.where((n) => n.isSchoolNotice && !appState.isNoticeRead(n.id)).length;
    final classUnread = allNotices.where((n) => n.isClassNotice && !appState.isNoticeRead(n.id)).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChipItem(
            filter: NoticeFilterType.all,
            label: 'All',
          ),
          const SizedBox(width: 8),
          _buildChipItem(
            filter: NoticeFilterType.unread,
            label: 'Unread',
            count: unreadCount > 0 ? unreadCount : null,
          ),
          const SizedBox(width: 8),
          _buildChipItem(
            filter: NoticeFilterType.school,
            label: 'schoolNotice'.tr(),
            count: schoolUnread > 0 ? schoolUnread : null,
          ),
          const SizedBox(width: 8),
          _buildChipItem(
            filter: NoticeFilterType.classNotice,
            label: 'classNotice'.tr(),
            count: classUnread > 0 ? classUnread : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChipItem({
    required NoticeFilterType filter,
    required String label,
    int? count,
  }) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryTeal : Colors.white,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEA580C)
                      : const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, Notice notice, AppState appState) {
    final isUnread = !appState.isNoticeRead(notice.id);
    final isSchool = notice.isSchoolNotice;
    final themeColor = isSchool ? const Color(0xFFEA580C) : const Color(0xFF7C3AED);
    final bgIconColor = isSchool ? const Color(0xFFFFF7ED) : const Color(0xFFF5F3FF);
    final borderIconColor = isSchool ? const Color(0xFFFFEDD5) : const Color(0xFFEDE9FE);
    final iconData = isSchool ? LucideIcons.megaphone : LucideIcons.users;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread
                ? themeColor.withValues(alpha: 0.35)
                : const Color(0xFFE2E8F0),
            width: isUnread ? 1.2 : 1.0,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  const BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // 4.5px vertical accent stripe on left edge for unread notices
              if (isUnread)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4.5,
                    color: themeColor,
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    appState.markNoticeAsRead(notice.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoticeDetailScreen(notice: notice),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isUnread ? 18 : 16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isUnread ? bgIconColor : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUnread ? borderIconColor : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Icon(
                                iconData,
                                color: isUnread ? themeColor : const Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _formatNoticeSubtitle(notice),
                                        style: TextStyle(
                                          color: isUnread ? themeColor : const Color(0xFF64748B),
                                          fontSize: 11,
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                      if (isUnread) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: themeColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: themeColor.withValues(alpha: 0.3),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            'NEW',
                                            style: TextStyle(
                                              color: themeColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notice.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                      color: isUnread ? AppColors.textMain : const Color(0xFF334155),
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: isUnread ? AppColors.textMuted : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          notice.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnread ? const Color(0xFF4B5563) : const Color(0xFF64748B),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        if (notice.displayAttachments.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.paperclip, size: 12, color: Color(0xFF1D4ED8)),
                                const SizedBox(width: 4),
                                Text(
                                  '${notice.displayAttachments.length} ${notice.displayAttachments.length == 1 ? 'file' : 'files'} attached',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (notice.isGalleryNotice) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.25)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.images, size: 12, color: AppColors.primaryTeal),
                                SizedBox(width: 4),
                                Text(
                                  'Photos in Gallery',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allNotices = appState.notices;
    final currentChild = appState.currentChild;
    final isLoading = appState.isNoticesLoading;

    // 1. Filter by selected category / unread status
    final categoryFiltered = allNotices.where((notice) {
      switch (_selectedFilter) {
        case NoticeFilterType.all:
          return true;
        case NoticeFilterType.unread:
          return !appState.isNoticeRead(notice.id);
        case NoticeFilterType.school:
          return notice.isSchoolNotice;
        case NoticeFilterType.classNotice:
          return notice.isClassNotice;
      }
    }).toList();

    // 2. Filter by search query within the selected category
    final filteredNotices = categoryFiltered.where((notice) {
      final query = _searchTerm.toLowerCase().trim();
      if (query.isEmpty) return true;
      return notice.title.toLowerCase().contains(query) ||
          notice.body.toLowerCase().contains(query) ||
          notice.source.toLowerCase().contains(query) ||
          notice.category.toLowerCase().contains(query);
    }).toList();

    // 3. Sort descending by sent date/time
    filteredNotices.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final unreadFilteredCount = filteredNotices.where((n) => !appState.isNoticeRead(n.id)).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header (Compact, modern gradient container)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryTeal, Color(0xFF00695C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar / Search Bar
                if (_isSearchOpen)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchOpen = false;
                            _searchTerm = '';
                            _searchController.clear();
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (val) {
                              setState(() {
                                _searchTerm = val;
                              });
                            },
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search notices, circulars...',
                              hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                              prefixIcon: const Icon(LucideIcons.search, color: Colors.white70, size: 16),
                              suffixIcon: _searchTerm.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(LucideIcons.x, color: Colors.white70, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          _searchTerm = '';
                                          _searchController.clear();
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'noticeBoard'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currentChild.name} (${currentChild.grade})',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // WhatsApp-style double-check Mark All Read icon button
                          if (unreadFilteredCount > 0) ...[
                            GestureDetector(
                              onTap: () async {
                                await appState.markAllNoticesAsRead();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All notices marked as read'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.checkCheck, color: Colors.white, size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSearchOpen = true;
                              });
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.search, color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: isLoading ? null : _loadNotices,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                    )
                                  : const Icon(LucideIcons.refreshCw, color: Colors.white, size: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                // Horizontal Filter Chips
                _buildFilterChips(allNotices, appState),
              ],
            ),
          ),

          // Notices List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNotices,
              color: AppColors.primaryTeal,
              child: filteredNotices.isNotEmpty
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: filteredNotices.length,
                      itemBuilder: (context, index) {
                        final notice = filteredNotices[index];
                        return _buildNoticeCard(context, notice, appState);
                      },
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _selectedFilter == NoticeFilterType.unread
                                      ? const Color(0xFFECFDF5)
                                      : AppColors.primaryTeal.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _selectedFilter == NoticeFilterType.unread
                                      ? LucideIcons.sparkles
                                      : _getFilterIcon(_selectedFilter),
                                  size: 40,
                                  color: _selectedFilter == NoticeFilterType.unread
                                      ? const Color(0xFF059669)
                                      : AppColors.primaryTeal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == NoticeFilterType.unread && _searchTerm.isEmpty
                                    ? "You're all caught up! 🎉"
                                    : (_searchTerm.isNotEmpty
                                        ? 'No notices match "$_searchTerm"'
                                        : 'No notices found in ${_getFilterLabel(_selectedFilter)}'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _selectedFilter == NoticeFilterType.unread && _searchTerm.isEmpty
                                    ? 'No unread notices at the moment.'
                                    : (_searchTerm.isNotEmpty
                                        ? 'Try checking for typos or searching a different keyword'
                                        : 'Notices published in this category will appear here.'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoticeDetailScreen extends StatelessWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  String _formatFullDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open attachment link')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  Future<void> _navigateToGallery(BuildContext context, Notice notice) async {
    final appState = Provider.of<AppState>(context, listen: false);
    String? eventId = notice.eventId;
    if (eventId == null || eventId.isEmpty) {
      if (notice.externalUrl != null && notice.externalUrl!.isNotEmpty) {
        final uri = Uri.tryParse(notice.externalUrl!);
        eventId = uri?.queryParameters['eventId'];
      }
    }

    if (eventId != null && eventId.isNotEmpty) {
      Album? targetAlbum;
      try {
        targetAlbum = appState.albums.firstWhere(
          (a) => a.eventId == eventId || a.id == eventId,
        );
      } catch (_) {}

      if (targetAlbum != null) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlbumDetailScreen(album: targetAlbum),
            ),
          );
        }
        return;
      }

      // If album is not in memory yet, show brief loader and fetch gallery
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
      try {
        await appState.fetchGallery(appState.currentChild.id);
      } catch (_) {}
      if (context.mounted) {
        Navigator.pop(context); // close loader
        try {
          targetAlbum = appState.albums.firstWhere(
            (a) => a.eventId == eventId || a.id == eventId,
          );
        } catch (_) {}
        if (targetAlbum != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlbumDetailScreen(album: targetAlbum),
            ),
          );
          return;
        }
      }
    }

    // Fallback: open main GalleryScreen
    if (context.mounted) {
      Navigator.pushNamed(context, '/gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCta = notice.cta != null;
    final hasExternalUrl = notice.externalUrl != null && notice.externalUrl!.isNotEmpty;

    void handleCtaAction(BuildContext context, String action) {
      if (action == 'event') {
        Navigator.pushReplacementNamed(context, '/events');
      } else if (action == 'fees') {
        Navigator.pushReplacementNamed(context, '/fees');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notice Details',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryTeal, Color(0xFF00695C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A00838F),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              notice.isClassNotice ? LucideIcons.users : LucideIcons.megaphone,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              notice.source.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notice.isSchoolNotice ? 'schoolNotice'.tr() : 'classNotice'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    notice.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _formatFullDate(notice.date),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      if (notice.time.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        const Icon(LucideIcons.clock, color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          notice.time,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Message Body Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.fileText, color: AppColors.textMuted, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'MESSAGE'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    notice.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMain,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // Attachments Section
            if (notice.displayAttachments.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.paperclip, color: AppColors.primaryTeal, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'ATTACHMENTS (${notice.displayAttachments.length})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...notice.displayAttachments.map((att) {
                      final isPdf = att.name.toLowerCase().endsWith('.pdf') ||
                          att.contentType.contains('pdf');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isPdf
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isPdf ? LucideIcons.fileSpreadsheet : LucideIcons.file,
                              color: isPdf ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            att.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: att.formattedSize.isNotEmpty
                              ? Text(
                                  att.formattedSize,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                )
                              : null,
                          trailing: ElevatedButton.icon(
                            onPressed: att.url.isNotEmpty
                                ? () => _openUrl(context, att.url)
                                : null,
                            icon: const Icon(LucideIcons.externalLink, size: 14),
                            label: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // External CTA Action or Gallery Deep Link
            if (notice.isGalleryNotice) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToGallery(context, notice),
                  icon: const Icon(LucideIcons.images, size: 18),
                  label: Text(
                    notice.externalUrlLabel ?? 'View Album in Gallery',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.primaryTeal.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ] else if (hasExternalUrl) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openUrl(context, notice.externalUrl!),
                  icon: const Icon(LucideIcons.externalLink, size: 18),
                  label: Text(
                    notice.externalUrlLabel ?? 'Open Circular Link',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ] else if (hasCta) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => handleCtaAction(context, notice.cta!.action),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    notice.cta!.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
