import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/veyho_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentChild = appState.currentChild;
    final childAvatar = appState.childAvatars[currentChild.id];

    final menuItems = [
      {'icon': LucideIcons.user, 'title': 'studentProfile'.tr(), 'route': '/profile/child'},
      {'icon': LucideIcons.lock, 'title': 'changePassword'.tr(), 'route': '/profile/change-password'},
      {'icon': LucideIcons.globe, 'title': 'languageSettings'.tr(), 'route': '/profile/language'},
      {'icon': LucideIcons.messageSquare, 'title': 'feedback'.tr(), 'route': '/profile/feedback'},
      {'icon': LucideIcons.info, 'title': 'aboutUs'.tr(), 'route': '/profile/about'},
      {'icon': LucideIcons.circleHelp, 'title': 'help'.tr(), 'route': '/profile/help'},
      {'icon': LucideIcons.shieldAlert, 'title': 'privacySettings'.tr(), 'route': '/profile/privacy'},
    ];

    void handleLogout() {
      appState.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'profile'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
            // Student Card Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Profile Photo Frame
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: childAvatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.memory(
                              base64Decode(childAvatar),
                              width: 58,
                              height: 58,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              currentChild.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentChild.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentChild.grade,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${'rollNo'.tr()}: ${currentChild.studentId}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile menu items list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: menuItems.map((item) {
                  return ListTile(
                    leading: Icon(item['icon'] as IconData, color: AppColors.primaryTeal),
                    title: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 20),
                    onTap: () => Navigator.pushNamed(context, item['route'] as String),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: handleLogout,
                icon: const Icon(LucideIcons.logOut, color: Colors.white, size: 18),
                label: Text(
                  'logout'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(active: 'profile'),
    );
  }
}

// Child Student Details Profile screen
class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final child = appState.currentChild;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'studentProfile'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailItem('fullName'.tr(), child.name),
              const Divider(color: AppColors.border, height: 24),
              _buildDetailItem('class'.tr(), child.grade),
              const Divider(color: AppColors.border, height: 24),
              _buildDetailItem('enrollmentNo'.tr(), child.enrollmentNo),
              const Divider(color: AppColors.border, height: 24),
              _buildDetailItem('dob'.tr(), child.dob),
              const Divider(color: AppColors.border, height: 24),
              _buildDetailItem('gender'.tr(), child.gender),
              const Divider(color: AppColors.border, height: 24),
              _buildDetailItem('apaarId'.tr(), child.apaarId),
              const Divider(color: AppColors.border, height: 24),
              _buildDetailItem('penNo'.tr(), child.penNo),
              const Divider(color: AppColors.border, height: 24),
              _buildDetailItem('studentId'.tr(), child.studentId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Change Password mock Screen
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  void _savePassword() {
    if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) return;
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('passwordsDoNotMatch'.tr()), backgroundColor: AppColors.error),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('passwordUpdatedSuccessfully'.tr()), backgroundColor: AppColors.primaryTeal),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'changePassword'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _oldPassController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  labelText: 'currentPassword'.tr(),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPassController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  labelText: 'newPassword'.tr(),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPassController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  labelText: 'confirmNewPassword'.tr(),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('save'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Language selector Screen
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Widget buildLangOption(String code, String name) {
      final isSelected = appState.language == code;
      return ListTile(
        title: Text(
          name,
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: isSelected ? const Icon(LucideIcons.check, color: AppColors.primaryTeal) : null,
        onTap: () {
          appState.setLanguage(code);
          EasyLocalization.of(context)?.setLocale(Locale(code));
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'languageSettings'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildLangOption('en', 'English'),
              const Divider(color: AppColors.border, height: 1),
              buildLangOption('hi', 'हिंदी'),
              const Divider(color: AppColors.border, height: 1),
              buildLangOption('mr', 'मराठी'),
            ],
          ),
        ),
      ),
    );
  }
}

// Feedback screen
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _commentController = TextEditingController();

  void _submitFeedback() {
    if (_commentController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('feedbackSubmitted'.tr()), backgroundColor: AppColors.primaryTeal),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'feedback'.tr(),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _commentController,
                maxLines: 5,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: 'writeYourFeedbackHere'.tr(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('submit'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Informational details container for About Us, Help, and Privacy Settings
class MockDetailScreen extends StatelessWidget {
  final String title;
  final String bodyKey;

  const MockDetailScreen({super.key, required this.title, required this.bodyKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Text(
            bodyKey.tr(),
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'aboutUs'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: VeyhoLogo(fontSize: 40),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'aboutUs_heading'.tr(),
                  style: const TextStyle(
                    color: Color(0xFF0C1D37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'aboutUs_tagline'.tr(),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'aboutUs_desc1'.tr(),
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'aboutUs_desc2'.tr(),
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              _buildContactItem(LucideIcons.globe, 'www.veyho.com'),
              _buildContactItem(LucideIcons.mail, 'support@veyho.com'),
              _buildContactItem(LucideIcons.phone, '+91 80 4567 8900'),
              _buildContactItem(LucideIcons.mapPin, 'aboutUs_address'.tr()),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'VERSION 2.4.0',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2026 Veyho Technologies Pvt. Ltd. All rights reserved.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

