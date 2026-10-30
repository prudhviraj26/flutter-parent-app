import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'api_service.dart';
import 'device_info_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('[PushBackground] Handling background message: ${message.messageId}');
}

class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important school notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static bool _isInitialized = false;

  /// Initializes Firebase and Local Notification subsystems safely
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Firebase App if configured
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Setup Android notification channel
      if (!kIsWeb && Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_highImportanceChannel);
      }

      // 3. Initialize Local Notifications Plugin
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              handleNotificationPayload(data);
            } catch (e) {
              debugPrint('[LocalNotification] Payload parse error: $e');
            }
          }
        },
      );

      // 4. Foreground Message Listener -> Display Heads-Up Banner
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground] Received: ${message.notification?.title}');
        _showForegroundNotification(message);
      });

      // 5. Background Message Open Listener (App running in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM OpenedApp] User tapped notification from background');
        handleNotificationPayload(message.data);
      });

      // 6. Token Refresh Listener
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM] Token refreshed');
        final telemetry = await DeviceInfoService.getDeviceTelemetry();
        await ApiService.registerDeviceToken(
          deviceToken: newToken,
          platform: telemetry.platform,
          deviceUuid: telemetry.deviceUuid,
          deviceModel: telemetry.deviceModel,
          deviceManufacturer: telemetry.deviceManufacturer,
          osVersion: telemetry.osVersion,
          appVersion: telemetry.appVersion,
          locale: telemetry.locale,
          timezone: telemetry.timezone,
        );
      });

      _isInitialized = true;
      debugPrint('✓ [NotificationNavigationService] Successfully initialized');
    } catch (e) {
      debugPrint(
        '⚠️ [NotificationNavigationService] Firebase initialization note: $e',
      );
    }
  }

  /// Check if the app was launched by tapping a push notification from terminated state
  static Future<void> checkInitialNotification() async {
    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM Terminated] App launched from notification');
        // Small delay to ensure widget tree and Navigator are ready
        Future.delayed(const Duration(milliseconds: 600), () {
          handleNotificationPayload(initialMessage.data);
        });
      }
    } catch (e) {
      debugPrint('[FCM] checkInitialNotification error: $e');
    }
  }

  /// Displays foreground notification heads-up banner
  static void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _highImportanceChannel.id,
      _highImportanceChannel.name,
      channelDescription: _highImportanceChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2F6B8A), // AppColors.primaryTeal
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payloadString =
        message.data.isNotEmpty ? jsonEncode(message.data) : null;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: payloadString,
    );
  }

  /// Request push permission and register token with backend
  static Future<bool> requestPermissionAndRegister() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isAuthorized) {
        debugPrint('[FCM] Push permissions denied by user');
        return false;
      }

      // Fetch FCM Device Token
      String? token;
      try {
        token = await messaging.getToken();
      } catch (e) {
        debugPrint('[FCM] Error fetching APNs/FCM token: $e');
      }

      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM] Token obtained: ${token.substring(0, 15)}...');
        final telemetry = await DeviceInfoService.getDeviceTelemetry();
        await ApiService.registerDeviceToken(
          deviceToken: token,
          platform: telemetry.platform,
          deviceUuid: telemetry.deviceUuid,
          deviceModel: telemetry.deviceModel,
          deviceManufacturer: telemetry.deviceManufacturer,
          osVersion: telemetry.osVersion,
          appVersion: telemetry.appVersion,
          locale: telemetry.locale,
          timezone: telemetry.timezone,
        );
        return true;
      }
    } catch (e) {
      debugPrint('[FCM] requestPermissionAndRegister error: $e');
    }
    return false;
  }

  /// Deep-Link Routing with Child-Context Auto-Switching
  static Future<void> handleNotificationPayload(
      Map<String, dynamic> data) async {
    debugPrint('[NotificationNavigation] Handling payload: $data');

    final type = data['type']?.toString().toLowerCase();
    final studentId = data['studentId']?.toString();

    // 1. Child-Aware Auto-Switch:
    // If notification is bound to a specific student, auto-switch active child
    if (studentId != null && studentId.isNotEmpty) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        try {
          final appState = Provider.of<AppState>(context, listen: false);
          await appState.switchToChildById(studentId);
        } catch (e) {
          debugPrint('[NotificationNavigation] Sibling switch note: $e');
        }
      }
    }

    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('⚠️ NavigatorState is null. Cannot route.');
      return;
    }

    // 2. Screen Routing
    switch (type) {
      case 'chat':
        nav.pushNamed('/talk-to-teacher');
        break;
      case 'attendance':
        nav.pushNamed('/attendance');
        break;
      case 'notice':
      case 'broadcast':
      case 'school_notice':
      case 'class_notice':
        nav.pushNamed('/school-notice');
        break;
      case 'fees':
      case 'fee_due':
        nav.pushNamed('/fees');
        break;
      case 'event':
      case 'gallery':
        nav.pushNamed('/gallery');
        break;
      default:
        nav.pushNamed('/home');
        break;
    }
  }
}
