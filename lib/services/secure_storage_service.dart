import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _apiKeyKey = 'chatgpt_api_key';
  static const String _webhookUrlKey = 'alexa_webhook_url';
  static const String _userIdKey = 'user_id';
  static const String _deviceRegisteredKey = 'device_registered';
  static const String _conversationPrefix = 'conversation_';
  static const String _automationPrefix = 'automation_';

  // API Key Management
  static Future<void> saveChatGPTApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  static Future<String?> getChatGPTApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  static Future<void> deleteChatGPTApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }

  // Webhook URL Management
  static Future<void> saveWebhookUrl(String webhookUrl) async {
    await _storage.write(key: _webhookUrlKey, value: webhookUrl);
  }

  static Future<String?> getWebhookUrl() async {
    return await _storage.read(key: _webhookUrlKey);
  }

  static Future<void> deleteWebhookUrl() async {
    await _storage.delete(key: _webhookUrlKey);
  }

  // User Management
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<void> saveDeviceRegistered(bool registered) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deviceRegisteredKey, registered);
  }

  static Future<bool> isDeviceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deviceRegisteredKey) ?? false;
  }

  // Conversation Storage (using SharedPreferences for simplicity)
  static Future<void> saveConversation(String conversationId, String conversationJson) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _conversationPrefix + conversationId;
    await prefs.setString(key, conversationJson);
  }

  static Future<String?> getConversation(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _conversationPrefix + conversationId;
    return prefs.getString(key);
  }

  static Future<void> deleteConversation(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _conversationPrefix + conversationId;
    await prefs.remove(key);
  }

  static Future<List<String>> getAllConversationIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys
        .where((key) => key.startsWith(_conversationPrefix))
        .map((key) => key.substring(_conversationPrefix.length))
        .toList();
  }

  // Automation Command Storage
  static Future<void> saveAutomationCommand(String commandId, String commandJson) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _automationPrefix + commandId;
    await prefs.setString(key, commandJson);
  }

  static Future<String?> getAutomationCommand(String commandId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _automationPrefix + commandId;
    return prefs.getString(key);
  }

  static Future<void> deleteAutomationCommand(String commandId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _automationPrefix + commandId;
    await prefs.remove(key);
  }

  static Future<List<String>> getAllAutomationCommandIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys
        .where((key) => key.startsWith(_automationPrefix))
        .map((key) => key.substring(_automationPrefix.length))
        .toList();
  }

  // Utility Methods
  static String generateSecureHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> clearAllData() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, String>> getAllSecureKeys() async {
    final Map<String, String> keys = {};
    
    final apiKey = await getChatGPTApiKey();
    if (apiKey != null) keys['chatgpt_api_key'] = '***configured***';
    
    final webhookUrl = await getWebhookUrl();
    if (webhookUrl != null) keys['alexa_webhook_url'] = webhookUrl;
    
    final userId = await getUserId();
    if (userId != null) keys['user_id'] = userId;
    
    final deviceRegistered = await isDeviceRegistered();
    keys['device_registered'] = deviceRegistered.toString();
    
    return keys;
  }
}
