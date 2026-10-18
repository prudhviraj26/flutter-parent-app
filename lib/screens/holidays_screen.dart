import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../constants/colors.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class HolidayTheme {
  final Color bg;
  final Color text;
  final Color border;

  const HolidayTheme({
    required this.bg,
    required this.text,
    required this.border,
  });
}

HolidayTheme getHolidayTheme(String name, String type) {
  final lower = name.toLowerCase();

  // 1. National Days (Emerald)
  if (lower.contains('republic') ||
      lower.contains('independence') ||
      lower.contains('gandhi')) {
    return const HolidayTheme(
      bg: Color(0xFFE8F5E9),
      text: Color(0xFF1B5E20),
      border: Color(0xFFA5D6A7),
    );
  }

  // 2. Joyous Festival of Lights & Colours (Warm Amber)
  if (lower.contains('diwali') ||
      lower.contains('deepavali') ||
      lower.contains('holi') ||
      lower.contains('dussehra') ||
      lower.contains('vijayadashami')) {
    return const HolidayTheme(
      bg: Color(0xFFFFF8E1),
      text: Color(0xFFB78103),
      border: Color(0xFFFFE082),
    );
  }

  // 3. Islamic Observances (Mint / Teal)
  if (lower.contains('eid') ||
      lower.contains('fitr') ||
      lower.contains('bakrid') ||
      lower.contains('muharram') ||
      lower.contains('milad')) {
    return const HolidayTheme(
      bg: Color(0xFFE0F2F1),
      text: Color(0xFF00695C),
      border: Color(0xFF80CBC4),
    );
  }

  // 4. Christian Observances (Soft Rose)
  if (lower.contains('christmas') ||
      lower.contains('good friday') ||
      lower.contains('easter')) {
    return const HolidayTheme(
      bg: Color(0xFFFFEBEE),
      text: Color(0xFFC2185B),
      border: Color(0xFFFFCDD2),
    );
  }

  // 5. Deities & Spiritual Gurus (Violet / Purple)
  if (lower.contains('janmashtami') ||
      lower.contains('ganesh') ||
      lower.contains('shivratri') ||
      lower.contains('mahavir') ||
      lower.contains('guru nanak') ||
      lower.contains('buddha')) {
    return const HolidayTheme(
      bg: Color(0xFFF3E5F5),
      text: Color(0xFF6A1B9A),
      border: Color(0xFFCE93D8),
    );
  }

  // 6. Social, Harvest, Sibling & Labour Festivals (Sky Blue)
  if (lower.contains('raksha') ||
      lower.contains('bhai') ||
      lower.contains('sankranti') ||
      lower.contains('pongal') ||
      lower.contains('ambedkar') ||
      lower.contains('labour') ||
      lower.contains('govardhan')) {
    return const HolidayTheme(
      bg: Color(0xFFE3F2FD),
      text: Color(0xFF1565C0),
      border: Color(0xFF90CAF9),
    );
  }

  // Fallbacks by holiday type
  final typeLower = type.toLowerCase();
  if (typeLower.contains('national')) {
    return const HolidayTheme(
      bg: Color(0xFFE8F5E9),
      text: Color(0xFF1B5E20),
      border: Color(0xFFA5D6A7),
    );
  }
  if (typeLower.contains('festival')) {
    return const HolidayTheme(
      bg: Color(0xFFFFF8E1),
      text: Color(0xFFB78103),
      border: Color(0xFFFFE082),
    );
  }
  if (typeLower.contains('bank')) {
    return const HolidayTheme(
      bg: Color(0xFFE3F2FD),
      text: Color(0xFF1565C0),
      border: Color(0xFF90CAF9),
    );
  }
  if (typeLower.contains('gazetted')) {
    return const HolidayTheme(
      bg: Color(0xFFE0F2F1),
      text: Color(0xFF00695C),
      border: Color(0xFF80CBC4),
    );
  }

  // Default Cool Slate
  return const HolidayTheme(
    bg: Color(0xFFF1F5F9),
    text: Color(0xFF475569),
    border: Color(0xFFCBD5E1),
  );
}

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  // Map of month group key (e.g. "2026-04") -> expanded bool
  final Map<String, bool> _expandedMonths = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHolidays();
    });
  }

  void _loadHolidays() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.fetchAcademicYearsAndHolidays(silent: false);
  }

  void _toggleAllMonths(List<String> monthKeys, bool expand) {
    setState(() {
      for (final key in monthKeys) {
        _expandedMonths[key] = expand;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final holidays = appState.holidays;
    final academicYears = appState.academicYears;
    final selectedYearId = appState.selectedAcademicYearId;
    final isLoading = appState.isHolidaysLoading;

    // Group holidays by year-month (e.g. "2026-04") sorted chronologically
    final Map<String, List<Holiday>> holidaysByMonth = {};
    for (final h in holidays) {
      final key = DateFormat('yyyy-MM').format(h.fullDate);
      holidaysByMonth.putIfAbsent(key, () => []).add(h);
    }

    // Sort entries chronologically by year-month
    final sortedMonthEntries = holidaysByMonth.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Sort holidays within each month by date
    for (final entry in sortedMonthEntries) {
      entry.value.sort((a, b) => a.fullDate.compareTo(b.fullDate));
    }

    final monthKeys = sortedMonthEntries.map((e) => e.key).toList();

    // Initialize all months expanded by default once data is loaded
    if (!_initialized && monthKeys.isNotEmpty) {
      for (final key in monthKeys) {
        _expandedMonths.putIfAbsent(key, () => true);
      }
      _initialized = true;
    }

    final bool allExpanded = monthKeys.isNotEmpty &&
        monthKeys.every((k) => _expandedMonths[k] == true);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'holidays'.tr(),
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await appState.fetchAcademicYearsAndHolidays(
            yearId: selectedYearId,
            silent: false,
          );
        },
        color: AppColors.primaryTeal,
        child: Column(
          children: [
            // Top Toolbar: Academic Year selector + count badge + Expand/Collapse toggle
            _buildTopToolbar(
              context: context,
              appState: appState,
              academicYears: academicYears,
              selectedYearId: selectedYearId,
              holidayCount: holidays.length,
              monthKeys: monthKeys,
              allExpanded: allExpanded,
            ),

            // Content list
            Expanded(
              child: isLoading && holidays.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryTeal),
                    )
                  : sortedMonthEntries.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: sortedMonthEntries.length,
                          itemBuilder: (context, idx) {
                            final entry = sortedMonthEntries[idx];
                            final monthKey = entry.key;
                            final monthHolidays = entry.value;
                            final isExpanded = _expandedMonths[monthKey] ?? true;

                            // Title formatted as "April 2026", "January 2027"
                            final displayMonthTitle = DateFormat('MMMM yyyy')
                                .format(monthHolidays.first.fullDate);

                            return _buildMonthAccordion(
                              monthKey: monthKey,
                              displayTitle: displayMonthTitle,
                              holidays: monthHolidays,
                              isExpanded: isExpanded,
                              onToggle: () {
                                setState(() {
                                  _expandedMonths[monthKey] = !isExpanded;
                                });
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Toolbar
  // ---------------------------------------------------------------------------
  Widget _buildTopToolbar({
    required BuildContext context,
    required AppState appState,
    required List<AcademicYearItem> academicYears,
    required String? selectedYearId,
    required int holidayCount,
    required List<String> monthKeys,
    required bool allExpanded,
  }) {
    // Current selected academic year item or fallback
    AcademicYearItem? selectedYear;
    if (academicYears.isNotEmpty) {
      selectedYear = academicYears.firstWhere(
        (y) => y.id == selectedYearId,
        orElse: () => academicYears.first,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Academic Year Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 14,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Year: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedYear?.id,
                        isDense: true,
                        icon: const Icon(
                          LucideIcons.chevronDown,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        items: academicYears.isNotEmpty
                            ? academicYears.map((y) {
                                return DropdownMenuItem<String>(
                                  value: y.id,
                                  child: Text(
                                    y.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList()
                            : [
                                DropdownMenuItem<String>(
                                  value: selectedYearId ?? '2026-27',
                                  child: Text(
                                    selectedYear?.name ?? '2026-27',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                        onChanged: (newId) {
                          if (newId != null && newId != selectedYearId) {
                            appState.setSelectedAcademicYearId(newId);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Total Holidays badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Text(
                  '$holidayCount ${holidayCount == 1 ? 'holiday' : 'holidays'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),

              const Spacer(),

              // Expand / Collapse All Toggle Button
              if (monthKeys.isNotEmpty)
                InkWell(
                  onTap: () => _toggleAllMonths(monthKeys, !allExpanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          allExpanded
                              ? LucideIcons.chevronsDownUp
                              : LucideIcons.chevronsUpDown,
                          size: 13,
                          color: const Color(0xFF475569),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          allExpanded ? 'Collapse All' : 'Expand All',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Month Accordion
  // ---------------------------------------------------------------------------
  Widget _buildMonthAccordion({
    required String monthKey,
    required String displayTitle,
    required List<Holiday> holidays,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Accordion Header
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: isExpanded ? const Color(0xFFF8FAFC) : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Expand / Collapse Chevron icon with rotation
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            LucideIcons.chevronRight,
                            size: 14,
                            color: isExpanded
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Month & Year title (e.g. "April 2026")
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Month count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          '${holidays.length} ${holidays.length == 1 ? 'holiday' : 'holidays'}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Collapsed Preview Chips (matching web app look!)
                  if (!isExpanded && holidays.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: holidays.map((h) {
                          final theme = getHolidayTheme(h.title, h.type);
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.bg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.border, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${h.date} ${h.month}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.text,
                                  ),
                                ),
                                Text(
                                  ' - ${h.title}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: theme.text,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded Content: Holiday Cards list
          if (isExpanded) ...[
            Container(color: const Color(0xFFE2E8F0), height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: holidays.length,
              separatorBuilder: (context, i) => const Divider(
                color: Color(0xFFF1F5F9),
                height: 14,
                thickness: 1,
              ),
              itemBuilder: (context, idx) {
                final holiday = holidays[idx];
                final theme = getHolidayTheme(holiday.title, holiday.type);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Calendar Date Badge Block
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.border, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            holiday.month.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.text,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            holiday.date,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.text,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title, Date info, Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holiday.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${holiday.date} ${holiday.month} ${holiday.fullDate.year} • ${holiday.day}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (holiday.description != null &&
                              holiday.description!.trim().isNotEmpty &&
                              holiday.description != holiday.title) ...[
                            const SizedBox(height: 2),
                            Text(
                              holiday.description!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Category Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: theme.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.border, width: 0.8),
                      ),
                      child: Text(
                        holiday.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.text,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                LucideIcons.calendarOff,
                size: 28,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No holidays scheduled',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No holidays have been published for this academic year yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
