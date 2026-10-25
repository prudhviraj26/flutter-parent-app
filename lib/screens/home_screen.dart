import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/child_switcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showChildDropdown = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentChild = appState.currentChild;

    // Retrieve active student metrics from state
    final classUpdates = appState.classUpdates;
    final fees = appState.fees;
    final events = appState.events;

    final pendingHomework = classUpdates.where((u) => u.type == 'Homework').length;
    final childAvatar = appState.childAvatars[currentChild.id];

    // School name dynamic
    final String schoolName = appState.currentSchoolName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Bar
          Container(
            color: AppColors.primaryTeal,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left School & Pupil details
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: appState.schoolLogoBase64 != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.memory(
                                          base64Decode(appState.schoolLogoBase64!),
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : (appState.schoolLogoUrl != null && appState.schoolLogoUrl!.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.network(
                                              appState.schoolLogoUrl!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                LucideIcons.school,
                                                color: AppColors.primaryTeal,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            LucideIcons.school,
                                            color: AppColors.primaryTeal,
                                          )),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schoolName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showChildDropdown = !_showChildDropdown;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentChild.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              LucideIcons.chevronDown,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right child profile button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            alignment: Alignment.center,
                            child: childAvatar != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      base64Decode(childAvatar),
                                      width: 34,
                                      height: 34,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (currentChild.photoUrl != null && currentChild.photoUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          currentChild.photoUrl!,
                                          width: 34,
                                          height: 34,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              currentChild.name.isNotEmpty
                                                  ? currentChild.name.substring(0, 1).toUpperCase()
                                                  : 'S',
                                              style: const TextStyle(
                                                color: AppColors.primaryTeal,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          currentChild.name.isNotEmpty
                                              ? currentChild.name.substring(0, 1).toUpperCase()
                                              : 'S',
                                          style: const TextStyle(
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )),
                          ),
                        ),
                      ],
                    ),
                    if (_showChildDropdown)
                      ChildSwitcher(
                        onClose: () {
                          setState(() {
                            _showChildDropdown = false;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Body Items
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryTeal,
              onRefresh: () async {
                await appState.fetchLiveChildData(currentChild.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                  // 1. Notice Board Minimal Hero Card (Option B)
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryTeal, AppColors.primaryTealDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/school-notice'),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Row: 48x48 icon box + Bold "Notice Board" title + unread pill on the right
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    LucideIcons.megaphone,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'noticeBoard'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                if (appState.unreadNoticesCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${appState.unreadNoticesCount} new',
                                      style: const TextStyle(
                                        color: AppColors.primaryTeal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Bottom Row: Single concise definition line with a right arrow
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'noticeBoardSubtitle'.tr(),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  LucideIcons.arrowRight,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Class Updates & Attendance Rows
                  Row(
                    children: [
                      Expanded(
                        child: _buildDashboardTile(
                          onTap: () {
                            Navigator.pushNamed(context, '/class-update');
                          },
                          color: AppColors.primaryTeal,
                          icon: LucideIcons.bookOpen,
                          title: 'classUpdate'.tr(),
                          subtitle: '$pendingHomework ${'homeworkPending'.tr()}',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDashboardTile(
                          onTap: () {
                            Navigator.pushNamed(context, '/attendance');
                          },
                          color: AppColors.secondaryOrange,
                          icon: LucideIcons.userCheck,
                          title: 'attendance'.tr(),
                          subtitle: 'thisMonth'.tr(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Fees & Events Rows
                  Row(
                    children: [
                      Expanded(
                        child: _buildDashboardTile(
                          onTap: () {
                            Navigator.pushNamed(context, '/fees');
                          },
                          color: AppColors.secondaryOrange,
                          icon: LucideIcons.indianRupee,
                          title: 'fees'.tr(),
                          subtitle: fees.status == 'Due'
                              ? '₹${fees.amount.toInt().toString()} ${'due'.tr()}'
                              : 'allPaid'.tr(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDashboardTile(
                          onTap: () {
                            Navigator.pushNamed(context, '/events');
                          },
                          color: AppColors.primaryTeal,
                          icon: LucideIcons.calendar,
                          title: 'events'.tr(),
                          subtitle: '${events.length} ${'upcoming'.tr()}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. View All Sections full width button
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/all-sections');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'viewAllSections'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            LucideIcons.arrowRight,
                            color: AppColors.secondaryOrange,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(active: 'home'),
    );
  }

  Widget _buildDashboardTile({
    required VoidCallback onTap,
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
