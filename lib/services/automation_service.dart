import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/chatgpt_models.dart';
import '../services/secure_storage_service.dart';
import '../services/notification_service.dart';

class AutomationService {
  final Uuid _uuid = const Uuid();

  Future<String> setReminder(String reminderText) async {
    try {
      final automation = AutomationCommand(
        id: _uuid.v4(),
        type: 'reminder',
        command: reminderText,
        parameters: {'text': reminderText, 'created_at': DateTime.now().toIso8601String()},
        timestamp: DateTime.now(),
        executed: false,
      );

      await SecureStorageService.saveAutomationCommand(
        automation.id,
        jsonEncode(automation.toJson()),
      );

      await NotificationService.showSimpleNotification(
        title: 'Reminder Set',
        body: 'Reminder: $reminderText',
      );

      return 'Reminder set: $reminderText';
    } catch (e) {
      return 'Failed to set reminder: $e';
    }
  }

  Future<String> setTimer(String timerText) async {
    try {
      // Parse timer duration from text (simple implementation)
      final duration = _parseTimerDuration(timerText);
      
      final automation = AutomationCommand(
        id: _uuid.v4(),
        type: 'timer',
        command: timerText,
        parameters: {
          'duration_seconds': duration.inSeconds,
          'created_at': DateTime.now().toIso8601String(),
        },
        timestamp: DateTime.now(),
        executed: false,
      );

      await SecureStorageService.saveAutomationCommand(
        automation.id,
        jsonEncode(automation.toJson()),
      );

      await NotificationService.showSimpleNotification(
        title: 'Timer Set',
        body: 'Timer for ${duration.inMinutes} minutes started',
      );

      // Schedule timer completion notification (simplified - in real app would use proper scheduling)
      _scheduleTimerNotification(duration, automation.id);

      return 'Timer set for ${duration.inMinutes} minutes';
    } catch (e) {
      return 'Failed to set timer: $e';
    }
  }

  Future<String> getWeather() async {
    try {
      // In a real implementation, this would call a weather API
      // For now, return a mock response
      final weatherInfo = '''
Current weather: 72°F, Partly Cloudy
Forecast: High 75°F, Low 65°F
Humidity: 65%
Wind: 5 mph
''';

      await NotificationService.showSimpleNotification(
        title: 'Weather Update',
        body: '72°F, Partly Cloudy',
      );

      return weatherInfo.trim();
    } catch (e) {
      return 'Failed to get weather: $e';
    }
  }

  Future<String> sendNotification(String notificationText) async {
    try {
      await NotificationService.showSimpleNotification(
        title: 'Custom Notification',
        body: notificationText,
      );

      return 'Notification sent: $notificationText';
    } catch (e) {
      return 'Failed to send notification: $e';
    }
  }

  Future<String> executeAutomationCommand(String automationId) async {
    try {
      final commandJson = await SecureStorageService.getAutomationCommand(automationId);
      if (commandJson == null) {
        return 'Automation command not found';
      }

      final Map<String, dynamic> json = jsonDecode(commandJson);
      final automation = AutomationCommand.fromJson(json);

      if (automation.executed) {
        return 'Automation already executed';
      }

      // Mark as executed
      final executedAutomation = AutomationCommand(
        id: automation.id,
        type: automation.type,
        command: automation.command,
        parameters: automation.parameters,
        timestamp: automation.timestamp,
        executed: true,
      );

      await SecureStorageService.saveAutomationCommand(
        automation.id,
        jsonEncode(executedAutomation.toJson()),
      );

      // Execute based on type
      String result;
      switch (automation.type) {
        case 'reminder':
          result = await _executeReminder(automation);
          break;
        case 'timer':
          result = await _executeTimer(automation);
          break;
        case 'smart_home':
          result = await _executeSmartHomeCommand(automation);
          break;
        default:
          result = 'Unknown automation type: ${automation.type}';
      }

      await NotificationService.showSimpleNotification(
        title: 'Automation Executed',
        body: result,
      );

      return result;
    } catch (e) {
      return 'Failed to execute automation: $e';
    }
  }

  Future<String> cancelAutomationCommand(String automationId) async {
    try {
      await SecureStorageService.deleteAutomationCommand(automationId);
      
      await NotificationService.showSimpleNotification(
        title: 'Automation Cancelled',
        body: 'The automation has been cancelled',
      );

      return 'Automation cancelled';
    } catch (e) {
      return 'Failed to cancel automation: $e';
    }
  }

  Future<List<AutomationCommand>> getPendingAutomations() async {
    try {
      final automationIds = await SecureStorageService.getAllAutomationCommandIds();
      final automations = <AutomationCommand>[];
      
      for (final id in automationIds) {
        final commandJson = await SecureStorageService.getAutomationCommand(id);
        if (commandJson != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(commandJson);
            final automation = AutomationCommand.fromJson(json);
            if (!automation.executed) {
              automations.add(automation);
            }
          } catch (e) {
            // Skip invalid automations
            continue;
          }
        }
      }
      
      // Sort by timestamp (newest first)
      automations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return automations;
    } catch (e) {
      return [];
    }
  }

  Future<String> _executeReminder(AutomationCommand automation) async {
    final text = automation.parameters?['text'] as String? ?? 'Reminder';
    return 'Reminder triggered: $text';
  }

  Future<String> _executeTimer(AutomationCommand automation) async {
    final duration = automation.parameters?['duration_seconds'] as int? ?? 0;
    return 'Timer completed after ${duration ~/ 60} minutes';
  }

  Future<String> _executeSmartHomeCommand(AutomationCommand automation) async {
    // In a real implementation, this would interface with smart home APIs
    return 'Smart home command executed: ${automation.command}';
  }

  Duration _parseTimerDuration(String timerText) {
    // Simple parsing - look for numbers and time units
    final regex = RegExp(r'(\d+)\s*(minute|hour|second)s?');
    final matches = regex.allMatches(timerText.toLowerCase());
    
    int totalSeconds = 0;
    
    for (final match in matches) {
      final number = int.parse(match.group(1)!);
      final unit = match.group(2)!;
      
      switch (unit) {
        case 'second':
          totalSeconds += number;
          break;
        case 'minute':
          totalSeconds += number * 60;
          break;
        case 'hour':
          totalSeconds += number * 3600;
          break;
      }
    }
    
    // Default to 5 minutes if no time found
    if (totalSeconds == 0) {
      totalSeconds = 300; // 5 minutes
    }
    
    return Duration(seconds: totalSeconds);
  }

  void _scheduleTimerNotification(Duration duration, String automationId) {
    // In a real implementation, this would use proper scheduling
    // For now, we'll just log that the timer was scheduled
    print('Timer scheduled for $duration with automation ID: $automationId');
    
    // Note: In a production app, you'd want to use:
    // - Background tasks
    // - Push notifications
    // - Or a proper scheduling service
  }

  Future<void> clearAutomationHistory() async {
    final automationIds = await SecureStorageService.getAllAutomationCommandIds();
    for (final id in automationIds) {
      await SecureStorageService.deleteAutomationCommand(id);
    }
  }
}
