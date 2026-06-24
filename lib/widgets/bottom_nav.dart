import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/colors.dart';

class BottomNav extends StatelessWidget {
  final String active;

  const BottomNav({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Tab
            _buildTab(
              context: context,
              icon: LucideIcons.house,
              label: 'home'.tr(),
              isActive: active == 'home',
              onTap: () {
                if (active != 'home') {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            // Message Tab
            _buildTab(
              context: context,
              icon: LucideIcons.messageCircle,
              label: 'talkToTeacher'.tr(),
              isActive: active == 'teacher',
              onTap: () {
                if (active != 'teacher') {
                  Navigator.pushReplacementNamed(context, '/talk-to-teacher');
                }
              },
            ),
            // Profile Tab
            _buildTab(
              context: context,
              icon: LucideIcons.user,
              label: 'profile'.tr(),
              isActive: active == 'profile',
              onTap: () {
                if (active != 'profile') {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color = isActive ? AppColors.primaryTeal : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
