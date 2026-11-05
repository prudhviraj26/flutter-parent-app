import 'package:flutter/material.dart';

/// Intercepts back navigation (hardware back button, back gesture, or leading button).
/// If the Navigator stack has an earlier route, it pops back to it.
/// If there is no previous route (e.g. accessed directly or via pushReplacement),
/// it safely redirects to the Home dashboard ('/home') instead of exiting the app.
class SafeBackScope extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;

  const SafeBackScope({
    super.key,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (onBack != null) {
          onBack!();
          return;
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: child,
    );
  }
}

