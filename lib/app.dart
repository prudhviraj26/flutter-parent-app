import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'state/app_state.dart';
import 'constants/colors.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/all_sections_screen.dart';
import 'screens/notice_screen.dart';
import 'screens/class_update_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/fees_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/payment_status_screen.dart';
import 'screens/payment_receipt_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/secondary_screens.dart';

class ParentApp extends StatelessWidget {
  const ParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'School Parent App',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            primaryColor: AppColors.primaryTeal,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryTeal,
              primary: AppColors.primaryTeal,
              secondary: AppColors.secondaryOrange,
              surface: AppColors.background,
            ),
            fontFamily: 'Inter',
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
              bodyLarge: TextStyle(fontSize: 16, color: AppColors.textMain),
              bodyMedium: TextStyle(fontSize: 14, color: AppColors.textMain),
              labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMain),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/all-sections': (context) => const AllSectionsScreen(),
            '/school-notice': (context) => const NoticeScreen(),
            '/class-update': (context) => const ClassUpdateScreen(),
            '/talk-to-teacher': (context) => const TalkToTeacherScreen(),
            '/fees': (context) => const FeesScreen(),
            '/fees/payment-method': (context) => const PaymentMethodScreen(),
            '/fees/payment-status': (context) => const PaymentStatusScreen(),
            '/fees/receipt': (context) => const PaymentReceiptScreen(),
            '/attendance': (context) => const AttendanceScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/profile/child': (context) => const ChildProfileScreen(),
            '/profile/change-password': (context) => const ChangePasswordScreen(),
            '/profile/language': (context) => const LanguageScreen(),
            '/profile/feedback': (context) => const FeedbackScreen(),
            '/profile/about': (context) => const AboutUsScreen(),
            '/profile/help': (context) => const HelpScreen(),
            '/profile/privacy': (context) => MockDetailScreen(title: 'privacySettings'.tr(), bodyKey: 'privacyBody'),
            
            // Secondary screens
            '/events': (context) => const EventsScreen(),
            '/events/detail': (context) => const EventDetailScreen(),
            '/holidays': (context) => const HolidaysScreen(),
            '/my-teachers': (context) => const MyTeachersScreen(),
            '/health-records': (context) => const HealthRecordsScreen(),
            '/library': (context) => const LibraryScreen(),
            '/bus-tracking': (context) => const BusTrackingScreen(),
            '/gallery': (context) => const GalleryScreen(),
            '/exam-results': (context) => const ExamResultsScreen(),
            '/exam-details': (context) => const ExamDetailsScreen(),
          },
        );
      },
    );
  }
}
