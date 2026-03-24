import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../models/alexa_models.dart';
import '../models/chatgpt_models.dart';
import '../services/chatgpt_service.dart';
import '../services/notification_service.dart';
import '../services/secure_storage_service.dart';
import '../services/automation_service.dart';

class AlexaWebhookServer {
  late HttpServer _server;
  late ChatGPTService _chatGPTService;
  late AutomationService _automationService;
  bool _isRunning = false;
  int _port = 8080;

  AlexaWebhookServer() {
    _chatGPTService = ChatGPTService();
    _automationService = AutomationService();
  }

  Future<void> start({int port = 8080}) async {
    if (_isRunning) {
      print('Server is already running on port $_port');
      return;
    }

    _port = port;
    final router = Router();

    // Health check endpoint
    router.get('/health', (Request request) {
      return Response.ok('OK', headers: {'Content-Type': 'text/plain'});
    });

    // Main webhook endpoint for Alexa
    router.post('/webhook/alexa', (Request request) async {
      return await _handleAlexaWebhook(request);
    });

    // Test endpoint
    router.post('/webhook/test', (Request request) async {
      return await _handleTestWebhook(request);
    });

    // Configure CORS
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(router);

    try {
      _server = await shelf_io.serve(handler, '0.0.0.0', _port);
      _isRunning = true;
      print('Alexa webhook server started on port $_port');
      print('Webhook URL: http://localhost:$_port/webhook/alexa');
    } catch (e) {
      print('Failed to start server: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    if (!_isRunning) return;
    
    await _server.close();
    _isRunning = false;
    print('Alexa webhook server stopped');
  }

  Future<Response> _handleAlexaWebhook(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      print('Received Alexa webhook: ${jsonEncode(data)}');

      // Validate required fields
      if (!_validateAlexaRequest(data)) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid Alexa request format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Parse the webhook payload
      final payload = AlexaWebhookPayload.fromJson(data);

      // Process the voice command
      final result = await _processVoiceCommand(payload);

      // Send notification to watch
      await NotificationService.showChatGPTResponse(
        title: 'Alexa Response',
        content: result,
        conversationId: payload.user_id,
      );

      // Return success response
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Command processed successfully',
          'response': result,
        }),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e) {
      print('Error processing Alexa webhook: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Failed to process command',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _handleTestWebhook(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      print('Received test webhook: ${jsonEncode(data)}');

      // Create test payload
      final payload = AlexaWebhookPayload(
        voice_input: data['voice_input'] ?? 'Test command',
        intent: data['intent'] ?? IntentType.chatGPTQuery,
        user_id: data['user_id'] ?? 'test_user',
        device_id: data['device_id'] ?? 'test_device',
        timestamp: DateTime.now(),
      );

      // Process the command
      final result = await _processVoiceCommand(payload);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'response': result,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e) {
      print('Error processing test webhook: $e');
      
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Failed to process test command',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<String> _processVoiceCommand(AlexaWebhookPayload payload) async {
    try {
      switch (payload.intent.toLowerCase()) {
        case 'chatgptquery':
        case 'chatgpt_query':
          return await _chatGPTService.sendMessage(payload.voice_input);

        case 'summarizetext':
        case 'summarize_text':
          return await _chatGPTService.summarizeText(payload.voice_input);

        case 'smarthomecommand':
        case 'smart_home_command':
          return await _processSmartHomeCommand(payload);

        case 'setreminder':
        case 'set_reminder':
          return await _automationService.setReminder(payload.voice_input);

        case 'settimer':
        case 'set_timer':
          return await _automationService.setTimer(payload.voice_input);

        case 'getweather':
        case 'get_weather':
          return await _automationService.getWeather();

        case 'sendnotification':
        case 'send_notification':
          return await _automationService.sendNotification(payload.voice_input);

        default:
          // Default to ChatGPT query for unrecognized intents
          return await _chatGPTService.sendMessage(payload.voice_input);
      }
    } catch (e) {
      return 'Sorry, I encountered an error processing your command: $e';
    }
  }

  Future<String> _processSmartHomeCommand(AlexaWebhookPayload payload) async {
    try {
      // Parse the smart home command using ChatGPT
      final commandJson = await _chatGPTService.processSmartHomeCommand(payload.voice_input);
      final commandData = jsonDecode(commandJson) as Map<String, dynamic>;

      // Create automation command
      final automation = AutomationCommand(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: commandData['device_type'] ?? 'unknown',
        command: payload.voice_input,
        parameters: commandData['parameters'] as Map<String, dynamic>?,
        timestamp: DateTime.now(),
        executed: false,
      );

      // Save automation command
      await SecureStorageService.saveAutomationCommand(
        automation.id,
        jsonEncode(automation.toJson()),
      );

      // Show notification with action buttons
      await NotificationService.showAutomationNotification(
        title: 'Smart Home Command',
        command: commandData['response'] ?? payload.voice_input,
        automationId: automation.id,
      );

      return commandData['response'] ?? 'Smart home command received';
    } catch (e) {
      return 'Failed to process smart home command: $e';
    }
  }

  bool _validateAlexaRequest(Map<String, dynamic> data) {
    // Check required fields for webhook payload
    final requiredFields = ['voice_input', 'intent', 'user_id', 'device_id'];
    
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        print('Missing required field: $field');
        return false;
      }
    }

    return true;
  }

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final response = await innerHandler(request);
        
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          ...response.headers,
        });
      };
    };
  }

  bool get isRunning => _isRunning;
  int get port => _port;

  Future<String> getWebhookUrl() async {
    try {
      // Get local IP address
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return 'http://${addr.address}:$_port/webhook/alexa';
          }
        }
      }
      return 'http://localhost:$_port/webhook/alexa';
    } catch (e) {
      return 'http://localhost:$_port/webhook/alexa';
    }
  }
}
