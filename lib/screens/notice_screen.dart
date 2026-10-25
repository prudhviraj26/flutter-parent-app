import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';

enum NoticeFilterType {
  all,
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
      case NoticeFilterType.school:
        return LucideIcons.megaphone;
      case NoticeFilterType.classNotice:
        return LucideIcons.users;
    }
  }

  Color _getFilterColor(NoticeFilterType filter) {
    switch (filter) {
      case NoticeFilterType.all:
        return AppColors.primaryTeal;
      case NoticeFilterType.school:
        return const Color(0xFFEA580C);
      case NoticeFilterType.classNotice:
        return const Color(0xFF7C3AED);
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

  Widget _buildFilterTrigger() {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getFilterColor(_selectedFilter).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFilterIcon(_selectedFilter),
                size: 16,
                color: _getFilterColor(_selectedFilter),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _getFilterLabel(_selectedFilter),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevronDown,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(sheetContext).padding.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'selectCategory'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Options
              _buildBottomSheetOption(
                sheetContext: sheetContext,
                filter: NoticeFilterType.all,
                title: 'allNotices'.tr(),
                icon: LucideIcons.layers,
                iconColor: AppColors.primaryTeal,
              ),
              const SizedBox(height: 8),
              _buildBottomSheetOption(
                sheetContext: sheetContext,
                filter: NoticeFilterType.school,
                title: 'schoolNotice'.tr(),
                icon: LucideIcons.megaphone,
                iconColor: const Color(0xFFEA580C),
              ),
              const SizedBox(height: 8),
              _buildBottomSheetOption(
                sheetContext: sheetContext,
                filter: NoticeFilterType.classNotice,
                title: 'classNotice'.tr(),
                icon: LucideIcons.users,
                iconColor: const Color(0xFF7C3AED),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required BuildContext sheetContext,
    required NoticeFilterType filter,
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
          Navigator.pop(sheetContext);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? iconColor.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? iconColor.withValues(alpha: 0.3) : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.textMain : const Color(0xFF4B5563),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  LucideIcons.check,
                  size: 20,
                  color: iconColor,
                ),
            ],
          ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread
                ? themeColor.withValues(alpha: 0.45)
                : AppColors.border,
            width: isUnread ? 1.5 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
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
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        color: bgIconColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderIconColor),
                      ),
                      child: Icon(iconData, color: themeColor, size: 20),
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
                                  color: themeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: themeColor,
                                    shape: BoxShape.circle,
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
                              color: AppColors.textMain,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notice.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                if (notice.attachments.isNotEmpty) ...[
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
                          '${notice.attachments.length} ${notice.attachments.length == 1 ? 'file' : 'files'} attached',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allNotices = appState.notices;
    final currentChild = appState.currentChild;
    final childAvatar = appState.childAvatars[currentChild.id];
    final isLoading = appState.isNoticesLoading;

    // 1. Filter by selected category
    final categoryFiltered = allNotices.where((notice) {
      switch (_selectedFilter) {
        case NoticeFilterType.all:
          return true;
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
          // Header & Search
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryTeal, Color(0xFF00695C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'noticeBoard'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (unreadFilteredCount > 0)
                          GestureDetector(
                            onTap: () => appState.markAllNoticesAsRead(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.checkCheck, color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Mark all read',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(LucideIcons.refreshCw, color: Colors.white, size: 18),
                          onPressed: isLoading ? null : _loadNotices,
                          tooltip: 'Refresh Notices',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Active Child Pill & Notices count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.white24,
                            backgroundImage: (childAvatar != null && childAvatar.isNotEmpty)
                                ? MemoryImage(base64Decode(childAvatar))
                                : null,
                            child: (childAvatar == null || childAvatar.isEmpty)
                                ? Text(
                                    currentChild.name.isNotEmpty ? currentChild.name[0] : 'S',
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${currentChild.name} (${currentChild.grade})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (allNotices.isNotEmpty)
                      Text(
                        '${filteredNotices.length} notices • $unreadFilteredCount unread',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Search Bar
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchTerm = val;
                    });
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.search, color: Colors.white70, size: 18),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, color: Colors.white70, size: 16),
                            onPressed: () => setState(() => _searchTerm = ''),
                          )
                        : null,
                    hintText: 'Search notices, circulars...',
                    hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Dropdown Filter Bar
                _buildFilterTrigger(),
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
                                  color: AppColors.primaryTeal.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getFilterIcon(_selectedFilter),
                                  size: 40,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchTerm.isNotEmpty
                                    ? 'No notices match "$_searchTerm"'
                                    : 'No notices found in ${_getFilterLabel(_selectedFilter)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchTerm.isNotEmpty
                                    ? 'Try checking for typos or searching a different keyword'
                                    : 'Notices published in this category will appear here.',
                                style: const TextStyle(
                                  fontSize: 12,
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
            if (notice.attachments.isNotEmpty) ...[
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
                          'ATTACHMENTS (${notice.attachments.length})',
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
                    ...notice.attachments.map((att) {
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

            // External CTA Action
            if (hasExternalUrl) ...[
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
