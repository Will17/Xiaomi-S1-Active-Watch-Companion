import 'package:flutter/foundation.dart';
import '../models/chatgpt_models.dart';
import '../services/secure_storage_service.dart';
import '../services/chatgpt_service.dart';
import '../services/alexa_webhook_server.dart';
import '../services/notification_service.dart';
import '../services/automation_service.dart';

class AppProvider extends ChangeNotifier {
  ChatGPTService _chatGPTService = ChatGPTService();
  AutomationService _automationService = AutomationService();
  AlexaWebhookServer? _webhookServer;
  
  // State variables
  bool _isLoading = false;
  bool _isWebhookServerRunning = false;
  String _webhookUrl = '';
  String _chatGPTApiKey = '';
  String _alexaWebhookUrl = '';
  List<Conversation> _conversations = [];
  List<AutomationCommand> _pendingAutomations = [];
  String _lastError = '';
  String _lastAlexaCommand = '';
  String _lastChatGPTResponse = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isWebhookServerRunning => _isWebhookServerRunning;
  String get webhookUrl => _webhookUrl;
  String get chatGPTApiKey => _chatGPTApiKey;
  String get alexaWebhookUrl => _alexaWebhookUrl;
  List<Conversation> get conversations => _conversations;
  List<AutomationCommand> get pendingAutomations => _pendingAutomations;
  String get lastError => _lastError;
  String get lastAlexaCommand => _lastAlexaCommand;
  String get lastChatGPTResponse => _lastChatGPTResponse;

  AppProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadConfiguration();
    await _loadConversations();
    await _loadPendingAutomations();
    await NotificationService.initialize();
  }

  Future<void> _loadConfiguration() async {
    try {
      _setLoading(true);
      
      final apiKey = await SecureStorageService.getChatGPTApiKey();
      final webhookUrl = await SecureStorageService.getWebhookUrl();
      
      _chatGPTApiKey = apiKey ?? '';
      _alexaWebhookUrl = webhookUrl ?? '';
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load configuration: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadConversations() async {
    try {
      _conversations = await _chatGPTService.getRecentConversations();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load conversations: $e');
    }
  }

  Future<void> _loadPendingAutomations() async {
    try {
      _pendingAutomations = await _automationService.getPendingAutomations();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load automations: $e');
    }
  }

  Future<bool> startWebhookServer({int port = 8080}) async {
    try {
      _setLoading(true);
      
      if (_webhookServer != null && _webhookServer!.isRunning) {
        await _webhookServer!.stop();
      }
      
      _webhookServer = AlexaWebhookServer();
      await _webhookServer!.start(port: port);
      
      _isWebhookServerRunning = true;
      _webhookUrl = await _webhookServer!.getWebhookUrl();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to start webhook server: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> stopWebhookServer() async {
    try {
      if (_webhookServer != null && _webhookServer!.isRunning) {
        await _webhookServer!.stop();
      }
      
      _isWebhookServerRunning = false;
      _webhookUrl = '';
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to stop webhook server: $e');
    }
  }

  Future<bool> saveChatGPTApiKey(String apiKey) async {
    try {
      _setLoading(true);
      
      await SecureStorageService.saveChatGPTApiKey(apiKey);
      _chatGPTApiKey = apiKey;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to save ChatGPT API key: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveAlexaWebhookUrl(String webhookUrl) async {
    try {
      _setLoading(true);
      
      await SecureStorageService.saveWebhookUrl(webhookUrl);
      _alexaWebhookUrl = webhookUrl;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to save Alexa webhook URL: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> sendChatGPTMessage(String message) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _chatGPTService.sendMessage(message);
      
      _lastChatGPTResponse = response;
      await _loadConversations(); // Refresh conversations
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to send ChatGPT message: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> summarizeText(String text) async {
    try {
      _setLoading(true);
      _clearError();
      
      final summary = await _chatGPTService.summarizeText(text);
      
      notifyListeners();
      return summary;
    } catch (e) {
      _setError('Failed to summarize text: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> processSmartHomeCommand(String command) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _chatGPTService.processSmartHomeCommand(command);
      
      await _loadPendingAutomations(); // Refresh automations
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to process smart home command: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> setReminder(String reminderText) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _automationService.setReminder(reminderText);
      
      await _loadPendingAutomations(); // Refresh automations
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to set reminder: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> setTimer(String timerText) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _automationService.setTimer(timerText);
      
      await _loadPendingAutomations(); // Refresh automations
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to set timer: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> getWeather() async {
    try {
      _setLoading(true);
      _clearError();
      
      final weather = await _automationService.getWeather();
      
      notifyListeners();
      return weather;
    } catch (e) {
      _setError('Failed to get weather: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> executeAutomation(String automationId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _automationService.executeAutomationCommand(automationId);
      
      await _loadPendingAutomations(); // Refresh automations
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to execute automation: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> cancelAutomation(String automationId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _automationService.cancelAutomationCommand(automationId);
      
      await _loadPendingAutomations(); // Refresh automations
      
      notifyListeners();
      return response;
    } catch (e) {
      _setError('Failed to cancel automation: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearConversationHistory() async {
    try {
      _setLoading(true);
      
      await _chatGPTService.clearConversationHistory();
      await _loadConversations();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear conversation history: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearAutomationHistory() async {
    try {
      _setLoading(true);
      
      await _automationService.clearAutomationHistory();
      await _loadPendingAutomations();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear automation history: $e');
    } finally {
      _setLoading(false);
    }
  }

  void updateLastAlexaCommand(String command) {
    _lastAlexaCommand = command;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    debugPrint('AppProvider Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _lastError = '';
    notifyListeners();
  }

  @override
  void dispose() {
    stopWebhookServer();
    super.dispose();
  }
}
