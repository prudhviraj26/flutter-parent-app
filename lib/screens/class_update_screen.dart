import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../constants/colors.dart';

enum ClassUpdateFilterType { all, classwork, homework }

class ClassUpdateScreen extends StatefulWidget {
  const ClassUpdateScreen({super.key});

  @override
  State<ClassUpdateScreen> createState() => _ClassUpdateScreenState();
}

class _ClassUpdateScreenState extends State<ClassUpdateScreen> {
  String _searchTerm = '';
  ClassUpdateFilterType _selectedFilter = ClassUpdateFilterType.all;
  bool _didApplyArg = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didApplyArg) {
      final arg = ModalRoute.of(context)?.settings.arguments as String?;
      if (arg == 'Classwork') {
        _selectedFilter = ClassUpdateFilterType.classwork;
      } else if (arg == 'Homework') {
        _selectedFilter = ClassUpdateFilterType.homework;
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

  String _getFilterLabel(ClassUpdateFilterType filter) {
    switch (filter) {
      case ClassUpdateFilterType.all:
        return 'allUpdates'.tr();
      case ClassUpdateFilterType.classwork:
        return 'classWork'.tr();
      case ClassUpdateFilterType.homework:
        return 'homeWork'.tr();
    }
  }

  IconData _getFilterIcon(ClassUpdateFilterType filter) {
    switch (filter) {
      case ClassUpdateFilterType.all:
        return LucideIcons.layers;
      case ClassUpdateFilterType.classwork:
        return LucideIcons.fileText;
      case ClassUpdateFilterType.homework:
        return LucideIcons.bookOpen;
    }
  }

  Color _getFilterColor(ClassUpdateFilterType filter) {
    switch (filter) {
      case ClassUpdateFilterType.all:
        return AppColors.primaryTeal;
      case ClassUpdateFilterType.classwork:
        return const Color(0xFF2563EB);
      case ClassUpdateFilterType.homework:
        return const Color(0xFF059669);
    }
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
            const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.textMuted),
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
                filter: ClassUpdateFilterType.all,
                title: 'allUpdates'.tr(),
                icon: LucideIcons.layers,
                iconColor: AppColors.primaryTeal,
              ),
              const SizedBox(height: 8),
              _buildBottomSheetOption(
                sheetContext: sheetContext,
                filter: ClassUpdateFilterType.classwork,
                title: 'classWork'.tr(),
                icon: LucideIcons.fileText,
                iconColor: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 8),
              _buildBottomSheetOption(
                sheetContext: sheetContext,
                filter: ClassUpdateFilterType.homework,
                title: 'homeWork'.tr(),
                icon: LucideIcons.bookOpen,
                iconColor: const Color(0xFF059669),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required BuildContext sheetContext,
    required ClassUpdateFilterType filter,
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

  Widget _buildClassUpdateCard(BuildContext context, ClassUpdate update) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassUpdateDetailScreen(update: update),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                          color: bgIconColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderIconColor, width: 1),
                        ),
                        child: Icon(iconData, size: 20, color: themeColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type & Date
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: bgIconColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: borderIconColor, width: 0.8),
                                  ),
                                  child: Text(
                                    typeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: themeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  update.date,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Subject & Title
                            Text(
                              update.title.isNotEmpty ? '${update.subject}: ${update.title}' : update.subject,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
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
                  if (update.body.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      update.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
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
                          const Icon(LucideIcons.user, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${'by'.tr()} ${update.teacher}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final updates = appState.classUpdates;
    final currentChild = appState.currentChild;
    final childAvatar = appState.childAvatars[currentChild.id];
    final isLoading = appState.isClassUpdatesLoading;

    // 1. Filter by category
    final categoryFiltered = updates.where((u) {
      switch (_selectedFilter) {
        case ClassUpdateFilterType.all:
          return true;
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
                          'classUpdate'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.refreshCw, color: Colors.white, size: 18),
                      onPressed: isLoading ? null : _loadUpdates,
                      tooltip: 'Refresh Updates',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Active Child Pill & Updates count
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
                                    currentChild.name.isNotEmpty ? currentChild.name[0].toUpperCase() : 'C',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${currentChild.name} (${currentChild.grade})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredUpdates.length} updates',
                      style: const TextStyle(
                        color: Colors.white70,
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
                    hintText: 'Search homework, classwork, subject...',
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
                        return _buildClassUpdateCard(context, update);
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
                                    ? 'No updates match "$_searchTerm"'
                                    : 'noUpdatesFound'.tr(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchTerm.isNotEmpty
                                    ? 'Try checking for typos or searching another subject'
                                    : 'Classwork and homework assigned by teachers will appear here.',
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

class ClassUpdateDetailScreen extends StatelessWidget {
  final ClassUpdate update;

  const ClassUpdateDetailScreen({super.key, required this.update});

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
                            onTap: () => _openUrl(context, file),
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
