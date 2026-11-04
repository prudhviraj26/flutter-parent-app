import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../constants/colors.dart';

class FeatureItem {
  final String name;
  final IconData icon;
  final String path;
  final Object? arguments;
  final Color color;
  final String? badgeText;

  FeatureItem({
    required this.name,
    required this.icon,
    required this.path,
    this.arguments,
    required this.color,
    this.badgeText,
  });
}

class SectionGroup {
  final String title;
  final List<FeatureItem> features;

  SectionGroup({required this.title, required this.features});
}

class AllSectionsScreen extends StatelessWidget {
  const AllSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Compute unread counts for communication modules
    final noticeUnread = appState.unreadNoticesCount;
    final classUpdatesUnread = appState.unreadClassUpdatesCount;

    // Compute upcoming events count
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingEventsCount = appState.events.where((e) {
      final dt = DateTime.tryParse(e.startDate) ?? DateTime.tryParse(e.date);
      return dt != null && !dt.isBefore(today);
    }).length;

    // Compute fees status
    final fees = appState.fees;
    final bool isFeeDue = fees.status.toLowerCase() == 'due' ||
        (fees.amount > 0 && fees.status.toLowerCase() != 'paid');

    final sections = [
      SectionGroup(
        title: 'schedule'.tr(),
        features: [
          FeatureItem(
            name: 'attendance'.tr(),
            icon: LucideIcons.userCheck,
            path: '/attendance',
            color: AppColors.secondaryOrange,
          ),
          FeatureItem(
            name: 'events'.tr(),
            icon: LucideIcons.calendar,
            path: '/events',
            color: AppColors.primaryTeal,
            badgeText: upcomingEventsCount > 0 ? '$upcomingEventsCount ${'upcoming'.tr()}' : null,
          ),
          FeatureItem(
            name: 'holidays'.tr(),
            icon: LucideIcons.plane,
            path: '/holidays',
            color: AppColors.primaryTeal,
          ),
        ],
      ),
      SectionGroup(
        title: 'communication'.tr(),
        features: [
          FeatureItem(
            name: 'noticeBoard'.tr(),
            icon: LucideIcons.megaphone,
            path: '/school-notice',
            color: AppColors.primaryTeal,
            badgeText: noticeUnread > 0 ? '$noticeUnread new' : null,
          ),
          FeatureItem(
            name: 'classUpdate'.tr(),
            icon: LucideIcons.bookOpen,
            path: '/class-update',
            color: AppColors.secondaryOrange,
            badgeText: classUpdatesUnread > 0 ? '$classUpdatesUnread new' : null,
          ),
        ],
      ),
      SectionGroup(
        title: 'schoolOnline'.tr(),
        features: [
          FeatureItem(
            name: 'myTeachers'.tr(),
            icon: LucideIcons.users,
            path: '/my-teachers',
            color: AppColors.secondaryOrange,
          ),
          FeatureItem(
            name: 'healthRecords'.tr(),
            icon: LucideIcons.heartPulse,
            path: '/health-records',
            color: AppColors.primaryTeal,
          ),
          FeatureItem(
            name: 'library'.tr(),
            icon: LucideIcons.book,
            path: '/library',
            color: AppColors.secondaryOrange,
          ),
          FeatureItem(
            name: 'gallery'.tr(),
            icon: LucideIcons.image,
            path: '/gallery',
            color: AppColors.primaryTeal,
          ),
        ],
      ),
      SectionGroup(
        title: 'schoolFee'.tr(),
        features: [
          FeatureItem(
            name: 'fees'.tr(),
            icon: LucideIcons.indianRupee,
            path: '/fees',
            color: AppColors.secondaryOrange,
            badgeText: isFeeDue ? 'Due' : null,
          ),
        ],
      ),
      SectionGroup(
        title: 'learning'.tr(),
        features: [
          FeatureItem(
            name: 'examResults'.tr(),
            icon: LucideIcons.award,
            path: '/exam-results',
            color: AppColors.primaryTeal,
          ),
          FeatureItem(
            name: 'examDetails'.tr(),
            icon: LucideIcons.fileText,
            path: '/exam-details',
            color: AppColors.secondaryOrange,
          ),
        ],
      ),
      SectionGroup(
        title: 'transport'.tr(),
        features: [
          FeatureItem(
            name: 'busTracking'.tr(),
            icon: LucideIcons.bus,
            path: '/bus-tracking',
            color: AppColors.primaryTeal,
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'viewAllSections'.tr(),
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
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: () async {
          if (appState.currentChild.id.isNotEmpty) {
            await appState.fetchLiveChildData(appState.currentChild.id);
          }
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: sections.length,
          itemBuilder: (context, sectionIdx) {
            final section = sections[sectionIdx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: section.features.length,
                    itemBuilder: (context, featureIdx) {
                      final feature = section.features[featureIdx];
                      return _buildFeatureCard(context, feature);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, FeatureItem feature) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            feature.path,
            arguments: feature.arguments,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: feature.color,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(feature.icon, color: Colors.white, size: 20),
                  ),
                  if (feature.badgeText != null && feature.badgeText!.isNotEmpty)
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          feature.badgeText!,
                          style: TextStyle(
                            color: feature.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                feature.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
