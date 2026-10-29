import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';
import '../services/attachment_local_store.dart';

enum ClassUpdateFilterType { all, unread, classwork, homework }

class ClassUpdateScreen extends StatefulWidget {
  const ClassUpdateScreen({super.key});

  @override
  State<ClassUpdateScreen> createState() => _ClassUpdateScreenState();
}

class _ClassUpdateScreenState extends State<ClassUpdateScreen> {
  String _searchTerm = '';
  ClassUpdateFilterType _selectedFilter = ClassUpdateFilterType.all;
  bool _didApplyArg = false;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didApplyArg) {
      final arg = ModalRoute.of(context)?.settings.arguments as String?;
      if (arg == 'Classwork') {
        _selectedFilter = ClassUpdateFilterType.classwork;
      } else if (arg == 'Homework') {
        _selectedFilter = ClassUpdateFilterType.homework;
      } else if (arg == 'Unread') {
        _selectedFilter = ClassUpdateFilterType.unread;
      }
      _didApplyArg = true;
    }
  }

  Future<void> _loadUpdates() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentChild.id.isNotEmpty) {
      await appState.fetchClassUpdates(appState.currentChild.id);
    }
  }

  IconData _getFilterIcon(ClassUpdateFilterType filter) {
    switch (filter) {
      case ClassUpdateFilterType.all:
        return LucideIcons.layers;
      case ClassUpdateFilterType.unread:
        return LucideIcons.sparkles;
      case ClassUpdateFilterType.classwork:
        return LucideIcons.fileText;
      case ClassUpdateFilterType.homework:
        return LucideIcons.bookOpen;
    }
  }

  Widget _buildFilterChips(List<ClassUpdate> allUpdates, AppState appState) {
    final unreadCount = allUpdates.where((u) => !appState.isClassUpdateRead(u.id)).length;
    final classworkUnread = allUpdates.where((u) => u.isClasswork && !appState.isClassUpdateRead(u.id)).length;
    final homeworkUnread = allUpdates.where((u) => u.isHomework && !appState.isClassUpdateRead(u.id)).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChipItem(
            filter: ClassUpdateFilterType.all,
            label: 'All',
          ),
          const SizedBox(width: 8),
          _buildChipItem(
            filter: ClassUpdateFilterType.unread,
            label: 'Unread',
            count: unreadCount > 0 ? unreadCount : null,
          ),
          const SizedBox(width: 8),
          _buildChipItem(
            filter: ClassUpdateFilterType.classwork,
            label: 'classWork'.tr(),
            count: classworkUnread > 0 ? classworkUnread : null,
          ),
          const SizedBox(width: 8),
          _buildChipItem(
            filter: ClassUpdateFilterType.homework,
            label: 'homeWork'.tr(),
            count: homeworkUnread > 0 ? homeworkUnread : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChipItem({
    required ClassUpdateFilterType filter,
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

  Widget _buildClassUpdateCard(BuildContext context, ClassUpdate update, AppState appState) {
    final isUnread = !appState.isClassUpdateRead(update.id);
    final isHomework = update.isHomework;
    final themeColor = isHomework ? const Color(0xFF059669) : const Color(0xFF2563EB);
    final bgIconColor = isHomework ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF);
    final borderIconColor = isHomework ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE);
    final iconData = isHomework ? LucideIcons.bookOpen : LucideIcons.fileText;
    final typeLabel = isHomework ? 'homeWork'.tr() : 'classWork'.tr();

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
              // 4.5px vertical accent stripe on left edge for unread updates
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
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    appState.markClassUpdateAsRead(update.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassUpdateDetailScreen(update: update),
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
                            // Leading Icon Box
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isUnread ? bgIconColor : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUnread ? borderIconColor : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                iconData,
                                size: 20,
                                color: isUnread ? themeColor : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Type, NEW Tag & Date
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isUnread ? bgIconColor : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isUnread ? borderIconColor : const Color(0xFFE2E8F0),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          typeLabel,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isUnread ? themeColor : const Color(0xFF64748B),
                                          ),
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
                                      const SizedBox(width: 6),
                                      Text(
                                        update.date,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isUnread ? AppColors.textMuted : const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  // Subject & Title
                                  Text(
                                    update.title.isNotEmpty ? '${update.subject}: ${update.title}' : update.subject,
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
                        if (update.body.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            update.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isUnread ? const Color(0xFF4B5563) : const Color(0xFF64748B),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Teacher Name
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.user,
                                  size: 12,
                                  color: isUnread ? AppColors.textMuted : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${'by'.tr()} ${update.teacher}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isUnread ? AppColors.textMuted : const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Attachments Pill
                            if (update.attachments.isNotEmpty)
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
                                      '${update.attachments.length} ${update.attachments.length == 1 ? 'file' : 'files'}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
    final updates = appState.classUpdates;
    final currentChild = appState.currentChild;
    final isLoading = appState.isClassUpdatesLoading;

    // 1. Filter by category / unread status
    final categoryFiltered = updates.where((u) {
      switch (_selectedFilter) {
        case ClassUpdateFilterType.all:
          return true;
        case ClassUpdateFilterType.unread:
          return !appState.isClassUpdateRead(u.id);
        case ClassUpdateFilterType.classwork:
          return u.isClasswork;
        case ClassUpdateFilterType.homework:
          return u.isHomework;
      }
    }).toList();

    // 2. Filter by search query
    final filteredUpdates = categoryFiltered.where((u) {
      final query = _searchTerm.toLowerCase().trim();
      if (query.isEmpty) return true;
      return u.subject.toLowerCase().contains(query) ||
          u.title.toLowerCase().contains(query) ||
          u.body.toLowerCase().contains(query) ||
          u.teacher.toLowerCase().contains(query);
    }).toList();

    // 3. Sort descending by date
    filteredUpdates.sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
                              hintText: 'Search homework, classwork, subject...',
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
                              'classUpdate'.tr(),
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
                          if (filteredUpdates.where((u) => !appState.isClassUpdateRead(u.id)).isNotEmpty) ...[
                            GestureDetector(
                              onTap: () async {
                                await appState.markAllClassUpdatesAsRead();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All class updates marked as read'),
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
                            onTap: isLoading ? null : _loadUpdates,
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
                _buildFilterChips(updates, appState),
              ],
            ),
          ),

          // Updates List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadUpdates,
              color: AppColors.primaryTeal,
              child: filteredUpdates.isNotEmpty
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: filteredUpdates.length,
                      itemBuilder: (context, index) {
                        final update = filteredUpdates[index];
                        return _buildClassUpdateCard(context, update, appState);
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
                                  color: _selectedFilter == ClassUpdateFilterType.unread
                                      ? const Color(0xFFECFDF5)
                                      : AppColors.primaryTeal.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _selectedFilter == ClassUpdateFilterType.unread
                                      ? LucideIcons.sparkles
                                      : _getFilterIcon(_selectedFilter),
                                  size: 40,
                                  color: _selectedFilter == ClassUpdateFilterType.unread
                                      ? const Color(0xFF059669)
                                      : AppColors.primaryTeal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == ClassUpdateFilterType.unread && _searchTerm.isEmpty
                                    ? "You're all caught up! 🎉"
                                    : (_searchTerm.isNotEmpty
                                        ? 'No updates match "$_searchTerm"'
                                        : 'noUpdatesFound'.tr()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _selectedFilter == ClassUpdateFilterType.unread && _searchTerm.isEmpty
                                    ? 'No unread class updates at the moment.'
                                    : (_searchTerm.isNotEmpty
                                        ? 'Try checking for typos or searching another subject'
                                        : 'Classwork and homework assigned by teachers will appear here.'),
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

class ClassUpdateDetailScreen extends StatelessWidget {
  final ClassUpdate update;

  const ClassUpdateDetailScreen({super.key, required this.update});

  Future<void> _openAttachment(BuildContext context, String fileUrl) async {
    final fileName = fileUrl.split('/').last.split('?').first;
    await AttachmentLocalStore.openAttachment(
      context: context,
      key: fileUrl,
      url: fileUrl,
      dateStr: update.date,
      originalFileName: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHomework = update.isHomework;
    final themeColor = isHomework ? const Color(0xFF059669) : const Color(0xFF2563EB);
    final typeLabel = isHomework ? 'homeWork'.tr() : 'classWork'.tr();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          typeLabel,
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
                              isHomework ? LucideIcons.bookOpen : LucideIcons.fileText,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              typeLabel.toUpperCase(),
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
                          update.subject,
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
                    update.title.isNotEmpty ? update.title : update.subject,
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
                        update.date,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 14),
                      const Icon(LucideIcons.user, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${'by'.tr()} ${update.teacher}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Instructions / Description Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
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
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.alignLeft,
                          size: 16,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Instructions',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    update.body.isNotEmpty ? update.body : 'No instructions provided.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Attachments Card
            if (update.attachments.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 6,
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
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.paperclip, size: 16, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${'attachments'.tr()} (${update.attachments.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...update.attachments.map((file) {
                      final fileName = file.split('/').last.split('?').first;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openAttachment(context, file),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.fileText, color: AppColors.primaryTeal, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName.isNotEmpty ? fileName : 'Attachment',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textMain,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Tap to open file',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(LucideIcons.externalLink, color: AppColors.textMuted, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
