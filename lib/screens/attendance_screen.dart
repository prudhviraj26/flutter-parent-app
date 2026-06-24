import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../constants/colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Static mock attendance screen

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final attendance = appState.attendance;

    final daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"];

    // Custom cell styles mimicking CSS styles in React app
    BoxDecoration getCellDecoration(String status) {
      const double radius = 12.0;
      switch (status) {
        case 'P':
          return BoxDecoration(
            color: const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0xFFB2EBF2).withValues(alpha: 0.8), width: 1),
          );
        case 'A':
          return BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0xFFFFCDD2).withValues(alpha: 0.8), width: 1),
          );
        case 'H':
          return BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0xFFBBDEFB).withValues(alpha: 0.8), width: 1),
          );
        case 'W':
          return BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.transparent),
          );
        default:
          return BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.grey[100]!),
          );
      }
    }

    Color getCellTextColor(String status) {
      switch (status) {
        case 'P':
          return const Color(0xFF00838F);
        case 'A':
          return const Color(0xFFC62828);
        case 'H':
          return const Color(0xFF1565C0);
        case 'W':
          return const Color(0xFFB0BEC5);
        default:
          return Colors.grey[400]!;
      }
    }

    final legendItems = [
      {'status': 'P', 'label': 'present'.tr(), 'color': AppColors.primaryTeal},
      {'status': 'A', 'label': 'absent'.tr(), 'color': const Color(0xFFEF5350)},
      {'status': 'H', 'label': 'holiday'.tr(), 'color': const Color(0xFF42A5F5)},
      {'status': 'W', 'label': 'weekend'.tr(), 'color': const Color(0xFFB0BEC5)},
    ];

    // Calendar keys
    final calendarDays = attendance.calendar.keys.toList();
    calendarDays.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Month Switcher
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Only June 2026 attendance is available in this demo."),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain, size: 20),
                    ),
                  ),
                  Text(
                    attendance.month,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Only June 2026 attendance is available in this demo."),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.chevronRight, color: AppColors.textMain, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary row present/absent
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA),
                      border: Border.all(color: const Color(0xFFB2EBF2).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'present'.tr().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00838F),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attendance.summary.present.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00838F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      border: Border.all(color: const Color(0xFFFFCDD2).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'absent'.tr().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attendance.summary.absent.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Grid Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
                children: [
                  // Legend Row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: legendItems.map((item) {
                        return Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  // Calendar Days Name Row
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: 7,
                    itemBuilder: (context, idx) {
                      return Center(
                        child: Text(
                          daysOfWeek[idx],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Calendar Days Numbers Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: calendarDays.length,
                    itemBuilder: (context, idx) {
                      final dayKey = calendarDays[idx];
                      final dayData = attendance.calendar[dayKey]!;
                      return Container(
                        decoration: getCellDecoration(dayData.status),
                        alignment: Alignment.center,
                        child: Text(
                          dayKey,
                          style: TextStyle(
                            color: getCellTextColor(dayData.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
