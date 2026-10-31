import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/veyho_logo.dart';
import '../constants/colors.dart';
import '../widgets/clickwrap_dialog.dart';
import '../services/device_info_service.dart';
import '../services/notification_navigation_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
    );

    _translateAnimation = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
    );

    // Stagger start
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });

    // Stagger redirect
    Timer(const Duration(milliseconds: 2300), () async {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        if (appState.loggedIn) {
          final needsConsent = await appState.checkNeedsLegalAssent();
          if (needsConsent && mounted) {
            final telemetry = await DeviceInfoService.getDeviceTelemetry();
            if (!mounted) return;
            final agreed = await ClickwrapDialog.show(
              context,
              activeDocs: appState.activeLegalDocs,
              deviceUuid: telemetry.deviceUuid,
            );
            if (!agreed) {
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
              return;
            }
            final termsDoc = appState.activeLegalDocs?['terms'] as Map<String, dynamic>?;
            final privacyDoc = appState.activeLegalDocs?['privacy'] as Map<String, dynamic>?;
            await appState.onLegalConsentAccepted(
              termsVersion: termsDoc?['version']?.toString() ?? 'v1.0.0',
              privacyVersion: privacyDoc?['version']?.toString() ?? 'v1.0.0',
            );
          }
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
            NotificationNavigationService.checkInitialNotification();
            NotificationNavigationService.requestPermissionAndRegister();
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Translucent Architectural Rings
          Positioned(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[100]!.withValues(alpha: 0.6), width: 1),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[50]!.withValues(alpha: 0.5), width: 1),
              ),
            ),
          ),

          // Main Logo Area
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _translateAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VeyhoLogo(fontSize: screenWidth * 0.13),
                              const SizedBox(height: 14),
                              Text(
                                'TECHNOLOGIES',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Loading Frame
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.primaryTeal,
                                backgroundColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'PARENT PORTAL',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
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
    );
  }
}
