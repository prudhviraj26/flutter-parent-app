import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/colors.dart';

class PushPermissionPrimerDialog extends StatelessWidget {
  const PushPermissionPrimerDialog({super.key});

  /// Displays the primer bottom sheet
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PushPermissionPrimerDialog(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        mediaQuery.padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),

          // Illustration icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                LucideIcons.bellRing,
                size: 36,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title & Subtitle
          const Text(
            'Never Miss School Updates',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay connected with real-time alerts about your child’s school day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Feature list
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                _BenefitRow(
                  icon: LucideIcons.userCheck,
                  title: 'Daily Attendance Alerts',
                  subtitle: 'Instant alerts when attendance is recorded',
                ),
                SizedBox(height: 12),
                _BenefitRow(
                  icon: LucideIcons.messageSquare,
                  title: 'Teacher Messages',
                  subtitle: 'Direct notifications for classroom chats',
                ),
                SizedBox(height: 12),
                _BenefitRow(
                  icon: LucideIcons.megaphone,
                  title: 'Circulars & Notices',
                  subtitle: 'Emergency holidays and school circulars',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Enable Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryOrange,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Enable Notifications',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary Not Now Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Not Now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primaryTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
