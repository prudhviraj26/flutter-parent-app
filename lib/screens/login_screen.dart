import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../constants/colors.dart';
import '../widgets/veyho_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final String mobile = _mobileController.text.replaceAll(RegExp(r'\D'), '');
    final String password = _passwordController.text;

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pleaseEnterValidMobile'.tr()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pleaseEnterPassword'.tr()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    appState.login(mobile);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String language = appState.language;

    // School Name Dynamic mapping
    String schoolName = appState.schoolConfig.name;
    if (language == 'mr') {
      schoolName = appState.schoolConfig.nameMarathi;
    } else if (language == 'hi') {
      schoolName = 'डेमो इंटरनेशनल स्कूल';
    }

    // Company Name Dynamic mapping
    String companyName = appState.veyhoBranding['companyName']!;
    if (language == 'mr') {
      companyName = appState.veyhoBranding['companyNameMarathi']!;
    } else if (language == 'hi') {
      companyName = 'वेहो टेक्नोलॉजीज';
    }

    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Illustration space
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(320, 200),
                  painter: IllustrationPainter(),
                ),
              ),
            ),

            // Login Input Card
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    schoolName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'parentPortal'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Phone Input
                  Text(
                    'mobileNumber'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.smartphone, color: AppColors.textMuted),
                      hintText: 'enterMobileNumber'.tr(),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.background,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  Text(
                    'password'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.lock, color: AppColors.textMuted),
                      hintText: 'enterPassword'.tr(),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.secondaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.secondaryOrange.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      'login'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'forgotPassword'.tr(),
                      style: const TextStyle(
                        color: AppColors.primaryTeal,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),

                  // Language selector row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLangChip(context, appState, 'en', 'English'),
                      const SizedBox(width: 8),
                      _buildLangChip(context, appState, 'hi', 'हिंदी'),
                      const SizedBox(width: 8),
                      _buildLangChip(context, appState, 'mr', 'मराठी'),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),

                  // Veyho logo & company name
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const VeyhoLogo(fontSize: 18),
                      const SizedBox(height: 4),
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangChip(BuildContext context, AppState appState, String code, String label) {
    final bool isSelected = appState.language == code;
    return GestureDetector(
      onTap: () {
        appState.setLanguage(code);
        // also set locale for easy_localization
        EasyLocalization.of(context)?.setLocale(Locale(code));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background shapes
    final Paint ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.2, h * 0.3), 20, ringPaint);
    canvas.drawCircle(Offset(w * 0.8, h * 0.4), 15, ringPaint);

    final Paint orangePaint = Paint()
      ..color = AppColors.secondaryOrange
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.7, h * 0.25, 40, 30),
        const Radius.circular(4),
      ),
      orangePaint,
    );

    // School Building (Center Card representation)
    final Paint cardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.5, 100, 80),
        const Radius.circular(8),
      ),
      cardPaint,
    );

    final Paint windowPaint = Paint()
      ..color = AppColors.primaryTeal.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.41, h * 0.55, 25, 25), const Radius.circular(4)),
      windowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.50, h * 0.55, 25, 25), const Radius.circular(4)),
      windowPaint,
    );

    final Paint doorPaint = Paint()
      ..color = AppColors.secondaryOrange
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.46, h * 0.725, 30, 35), const Radius.circular(4)),
      doorPaint,
    );

    // Draw little kids shapes (circles and rounded rects)
    final Paint skinPaint = Paint()
      ..color = const Color(0xFFFFD4A3)
      ..style = PaintingStyle.fill;
    final Paint clothesPaint = Paint()
      ..color = AppColors.secondaryOrange
      ..style = PaintingStyle.fill;

    // Kid 1
    canvas.drawCircle(Offset(w * 0.25, h * 0.7), 15, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.78, 24, 30), const Radius.circular(6)),
      clothesPaint,
    );

    // Kid 2
    canvas.drawCircle(Offset(w * 0.75, h * 0.7), 15, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.72, h * 0.78, 24, 30), const Radius.circular(6)),
      clothesPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
