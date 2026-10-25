import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import '../state/app_state.dart';
import '../constants/colors.dart';
import '../models/models.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendance();
    });
  }

  Future<void> _loadAttendance() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.fetchAttendanceForMonth(
      appState.currentChild.id,
      _selectedMonth,
      _selectedYear,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadAttendance();
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
    _loadAttendance();
  }

  BoxDecoration _getCellDecoration(String status, bool isToday) {
    const double radius = 10.0;
    Color bgColor;
    Color borderColor;

    switch (status) {
      case 'P':
        bgColor = const Color(0xFFE0F7FA);
        borderColor = const Color(0xFF80DEEA);
        break;
      case 'A':
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFFFCDD2);
        break;
      case 'L':
        bgColor = const Color(0xFFFFF8E1);
        borderColor = const Color(0xFFFFECB3);
        break;
      case 'HD':
        bgColor = const Color(0xFFEDE7F6);
        borderColor = const Color(0xFFD1C4E9);
        break;
      case 'H':
        bgColor = const Color(0xFFE3F2FD);
        borderColor = const Color(0xFFBBDEFB);
        break;
      case 'W':
        bgColor = const Color(0xFFF8F9FA);
        borderColor = Colors.transparent;
        break;
      default:
        bgColor = Colors.grey[50]!;
        borderColor = Colors.grey[200]!;
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      border: isToday
          ? Border.all(color: AppColors.primaryTeal, width: 2)
          : Border.all(color: borderColor, width: 1),
    );
  }

  Color _getCellTextColor(String status) {
    switch (status) {
      case 'P':
        return const Color(0xFF00838F);
      case 'A':
        return const Color(0xFFC62828);
      case 'L':
        return const Color(0xFFF57F17);
      case 'HD':
        return const Color(0xFF512DA8);
      case 'H':
        return const Color(0xFF1565C0);
      case 'W':
        return const Color(0xFF9E9E9E);
      default:
        return Colors.grey[400]!;
    }
  }

  String _getStatusFullName(String status) {
    switch (status) {
      case 'P':
        return 'Present';
      case 'A':
        return 'Absent';
      case 'L':
        return 'Late';
      case 'HD':
        return 'Half Day';
      case 'H':
        return 'School Holiday';
      case 'W':
        return 'Weekend';
      default:
        return 'Unmarked';
    }
  }

  Color _getStatusBadgeColor(String status) {
    switch (status) {
      case 'P':
        return const Color(0xFF00838F);
      case 'A':
        return const Color(0xFFC62828);
      case 'L':
        return const Color(0xFFF57F17);
      case 'HD':
        return const Color(0xFF512DA8);
      case 'H':
        return const Color(0xFF1565C0);
      case 'W':
        return const Color(0xFF757575);
      default:
        return Colors.grey[500]!;
    }
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color bg,
    required Color text,
    required Color border,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: text,
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showDayDetails(
    BuildContext context,
    int dayNumber,
    AttendanceCalendarDay? dayData,
  ) {
    final date = DateTime(_selectedYear, _selectedMonth, dayNumber);
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(date);
    final status = dayData?.status ?? '-';
    final statusName = _getStatusFullName(status);
    final reason = dayData?.reason ?? '';
    final notes = dayData?.notes ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBadgeColor(status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusBadgeColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              if (reason.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.info, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reason',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (notes.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.fileText, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Teacher Notes',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notes,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (reason.isEmpty && notes.isEmpty) ...[
                Row(
                  children: [
                    Icon(
                      status == 'P' ? LucideIcons.checkCircle2 : LucideIcons.calendar,
                      size: 18,
                      color: _getStatusBadgeColor(status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status == 'P'
                          ? 'Attended all scheduled classes'
                          : status == 'W'
                              ? 'Weekly school holiday'
                              : 'Status recorded by school administration',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final attendance = appState.attendance;
    final currentChild = appState.currentChild;
    final childAvatar = appState.childAvatars[currentChild.id];
    final isLoading = appState.isAttendanceLoading;

    final daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    // Compute month grid parameters
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final leadingEmptyCount = firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1...
    final totalGridCells = leadingEmptyCount + daysInMonth;

    final now = DateTime.now();
    final isCurrentMonth = now.year == _selectedYear && now.month == _selectedMonth;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'attendance'.tr(),
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
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textMain, size: 20),
            onPressed: isLoading ? null : _loadAttendance,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAttendance,
        color: AppColors.primaryTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryTeal,
                      ),
                      alignment: Alignment.center,
                      child: childAvatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.memory(
                                base64Decode(childAvatar),
                                width: 44,
                                height: 44,
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
                                fontSize: 18,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentChild.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentChild.enrollmentNo.isNotEmpty
                                ? '${currentChild.grade} • GR No: ${currentChild.enrollmentNo}'
                                : currentChild.grade,
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
              const SizedBox(height: 16),

              // Month Switcher
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain, size: 22),
                      onPressed: isLoading ? null : _goToPreviousMonth,
                      tooltip: 'Previous Month',
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendar, size: 16, color: AppColors.primaryTeal),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronRight, color: AppColors.textMain, size: 22),
                      onPressed: isLoading ? null : _goToNextMonth,
                      tooltip: 'Next Month',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4 Stats Chips: PRESENT, ABSENT, HALF DAY / LATE, HOLIDAYS
              Row(
                children: [
                  _buildStatChip(
                    label: 'present'.tr(),
                    value: '${attendance.summary.present}',
                    bg: const Color(0xFFE0F2F1),
                    text: const Color(0xFF00796B),
                    border: const Color(0xFFB2DFDB),
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    label: 'absent'.tr(),
                    value: '${attendance.summary.absent}',
                    bg: const Color(0xFFFFEBEE),
                    text: const Color(0xFFE11D48),
                    border: const Color(0xFFFFCDD2),
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    label: 'halfDay'.tr(),
                    value: '${attendance.summary.halfDay + attendance.summary.late}',
                    bg: const Color(0xFFFFF3E0),
                    text: const Color(0xFFEA580C),
                    border: const Color(0xFFFFE0B2),
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    label: 'holiday'.tr(),
                    value: '${attendance.summary.holiday}',
                    bg: const Color(0xFFECEFF1),
                    text: const Color(0xFF455A64),
                    border: const Color(0xFFCFD8DC),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar Grid Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    // Legend Row
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _buildLegendItem(const Color(0xFF00838F), 'present'.tr()),
                          _buildLegendItem(const Color(0xFFC62828), 'absent'.tr()),
                          _buildLegendItem(const Color(0xFFF57F17), 'Late'),
                          _buildLegendItem(const Color(0xFF1565C0), 'holiday'.tr()),
                          _buildLegendItem(const Color(0xFF9E9E9E), 'weekend'.tr()),
                        ],
                      ),
                    ),

                    // Weekdays Row (Sun..Sat)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: daysOfWeek.map((dayName) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: dayName == 'Sun' ? const Color(0xFFE57373) : Colors.grey[500],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Calendar Days Grid
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryTeal),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: totalGridCells,
                        itemBuilder: (context, idx) {
                          if (idx < leadingEmptyCount) {
                            return const SizedBox.shrink();
                          }

                          final dayNumber = idx - leadingEmptyCount + 1;
                          final dayKey = dayNumber.toString();
                          final dayData = attendance.calendar[dayKey];
                          final status = dayData?.status ?? '-';
                          final isToday = isCurrentMonth && now.day == dayNumber;

                          return InkWell(
                            onTap: () => _showDayDetails(context, dayNumber, dayData),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: _getCellDecoration(status, isToday),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayKey,
                                    style: TextStyle(
                                      color: _getCellTextColor(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (status == 'P') ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00838F),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ] else if (status == 'A') ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFC62828),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ] else if (status == 'L') ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF57F17),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ] else if (status == 'HD') ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF512DA8),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ] else if (status == 'H') ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1565C0),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary & Progress Card (Concise Teacher Duty Diary style)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.clipboardCheck,
                        color: AppColors.primaryTeal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Present for ${attendance.summary.present} out of ${attendance.summary.totalWorkingDays} working days',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Monthly attendance: ${attendance.summary.attendancePercentage}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Contextual Alert or Perfect Attendance Card
              if (attendance.summary.absent > 0)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    border: Border.all(color: const Color(0xFFFFE0B2)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.info, color: Color(0xFFEA580C), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${attendance.summary.absent} absence(s) recorded. Contact School Admin or Class Teacher for any discrepancies.',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC2410C),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.badgeCheck, color: Color(0xFF16A34A), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Full attendance maintained this month with zero absences recorded.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
