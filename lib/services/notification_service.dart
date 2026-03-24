import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          notificationCategories: [
            DarwinNotificationCategory(
              'chatgpt_response',
              actions: [
                DarwinNotificationAction.plain(
                  'summarize_again',
                  'Summarize Again',
                ),
                DarwinNotificationAction.plain('next_step', 'Next Step'),
              ],
            ),
            DarwinNotificationCategory(
              'automation',
              actions: [
                DarwinNotificationAction.plain('execute', 'Execute'),
                DarwinNotificationAction.plain('cancel', 'Cancel'),
              ],
            ),
          ],
        );

    InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (!kIsWeb) {
      await _createAndroidChannels();
    }

    _initialized = true;
  }

  static Future<void> _createAndroidChannels() async {
    const AndroidNotificationChannel chatGptChannel =
        AndroidNotificationChannel(
          'chatgpt_responses',
          'ChatGPT Responses',
          description: 'Notifications from ChatGPT responses',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification'),
        );

    const AndroidNotificationChannel automationChannel =
        AndroidNotificationChannel(
          'automation_commands',
          'Automation Commands',
          description: 'Smart home automation notifications',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification'),
        );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(chatGptChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(automationChannel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    debugPrint('Action ID: ${response.actionId}');

    // Handle notification actions
    switch (response.actionId) {
      case 'summarize_again':
        // Trigger re-summarization
        debugPrint('User requested to summarize again');
        break;
      case 'next_step':
        // Show next step or follow-up
        debugPrint('User requested next step');
        break;
      case 'execute':
        // Execute automation command
        debugPrint('User approved automation execution');
        break;
      case 'cancel':
        // Cancel automation
        debugPrint('User cancelled automation');
        break;
    }
  }

  static Future<void> showChatGPTResponse({
    required String title,
    required String content,
    String? conversationId,
  }) async {
    await initialize();

    // Format content for smartwatch display (max 2-3 lines)
    final formattedContent = _formatForWatch(content);

    NotificationDetails details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'chatgpt_response',
        threadIdentifier: conversationId ?? 'general',
      ),
      android: AndroidNotificationDetails(
        'chatgpt_responses',
        'ChatGPT Responses',
        channelDescription: 'Notifications from ChatGPT responses',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(formattedContent),
        actions: [
          AndroidNotificationAction('summarize_again', 'Summarize Again'),
          AndroidNotificationAction('next_step', 'Next Step'),
        ],
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      formattedContent,
      details,
      payload: conversationId,
    );
  }

  static Future<void> showAutomationNotification({
    required String title,
    required String command,
    String? automationId,
  }) async {
    await initialize();

    final formattedCommand = _formatForWatch(command);

    NotificationDetails details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'automation',
        threadIdentifier: automationId ?? 'automation',
      ),
      android: AndroidNotificationDetails(
        'automation_commands',
        'Automation Commands',
        channelDescription: 'Smart home automation notifications',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(formattedCommand),
        actions: [
          AndroidNotificationAction('execute', 'Execute'),
          AndroidNotificationAction('cancel', 'Cancel'),
        ],
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      formattedCommand,
      details,
      payload: automationId,
    );
  }

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    NotificationDetails details = NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'general',
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  static Future<void> showProgressNotification({
    required String title,
    required String content,
    int progress = 0,
    int maxProgress = 100,
  }) async {
    await initialize();

    NotificationDetails details = NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'progress',
        'Progress Notifications',
        channelDescription: 'Notifications showing progress',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      content,
      details,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  static String _formatForWatch(String content) {
    // Remove excessive whitespace
    content = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Split into sentences
    final sentences = content.split(RegExp(r'[.!?]+'));

    // Take first 2-3 sentences and limit character count
    final formatted = sentences
        .where((s) => s.trim().isNotEmpty)
        .take(3)
        .join('. ');

    // Limit to ~150 characters for smartwatch display
    if (formatted.length > 150) {
      return '${formatted.substring(0, 147)}...';
    }

    return formatted;
  }

  static Future<bool> hasPermission() async {
    final result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return result ?? false;
  }

  static Future<void> requestPermission() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}
