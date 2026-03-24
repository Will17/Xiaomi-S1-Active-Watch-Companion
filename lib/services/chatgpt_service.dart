import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/chatgpt_models.dart';
import '../services/secure_storage_service.dart';
import '../services/chatgpt_usage_service.dart';

class ChatGPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-4o-mini';
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  ChatGPTService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<String> sendMessage(String message, {String? conversationId}) async {
    try {
      final apiKey = await SecureStorageService.getChatGPTApiKey();
      if (apiKey == null) {
        throw Exception('ChatGPT API key not configured');
      }

      _dio.options.headers['Authorization'] = 'Bearer $apiKey';

      // Get or create conversation
      final convId = conversationId ?? _uuid.v4();
      Conversation conversation = await _getOrCreateConversation(convId);

      // Add user message
      final userMessage = ChatGPTMessage(role: 'user', content: message);
      final messages = [...conversation.messages, userMessage];

      // Create request
      final request = ChatGPTRequest(
        model: _defaultModel,
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000,
      );

      // Send to ChatGPT
      final response = await _dio.post('', data: request.toJson());

      final chatGptResponse = ChatGPTResponse.fromJson(response.data);

      if (chatGptResponse.choices.isEmpty) {
        throw Exception('No response from ChatGPT');
      }

      final assistantMessage = chatGptResponse.choices.first.message;

      // Update conversation with both messages
      final updatedMessages = [...messages, assistantMessage];
      final updatedConversation = conversation.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      await _saveConversation(updatedConversation);

      return assistantMessage.content;
    } catch (e) {
      throw Exception('Failed to send message to ChatGPT: $e');
    }
  }

  Future<String> summarizeText(String text, {int maxLength = 100}) async {
    try {
      final apiKey = await SecureStorageService.getChatGPTApiKey();
      if (apiKey == null) {
        throw Exception('ChatGPT API key not configured');
      }

      _dio.options.headers['Authorization'] = 'Bearer $apiKey';

      final prompt =
          '''
Please summarize the following text in a concise way, suitable for a smartwatch display. 
Keep it under $maxLength characters and use simple language.

Text to summarize:
$text
''';

      final request = ChatGPTRequest(
        model: _defaultModel,
        messages: [
          ChatGPTMessage(
            role: 'system',
            content:
                'You are a helpful assistant that creates concise summaries for smartwatch displays.',
          ),
          ChatGPTMessage(role: 'user', content: prompt),
        ],
        temperature: 0.3,
        max_tokens: 150,
      );

      final response = await _dio.post('', data: request.toJson());

      final chatGptResponse = ChatGPTResponse.fromJson(response.data);

      if (chatGptResponse.choices.isEmpty) {
        throw Exception('No response from ChatGPT');
      }

      return chatGptResponse.choices.first.message.content;
    } catch (e) {
      throw Exception('Failed to summarize text: $e');
    }
  }

  Future<String> processSmartHomeCommand(String command) async {
    try {
      final apiKey = await SecureStorageService.getChatGPTApiKey();
      if (apiKey == null) {
        throw Exception('ChatGPT API key not configured');
      }

      _dio.options.headers['Authorization'] = 'Bearer $apiKey';

      final prompt =
          '''
You are a smart home assistant. Analyze the following command and provide a structured response.
If it's a valid smart home command, identify the device type and action.
If it's unclear, ask for clarification.

Command: $command

Respond in JSON format:
{
  "device_type": "light|thermostat|lock|camera|speaker|other",
  "action": "turn_on|turn_off|set_temperature|lock|unlock|play_music|other",
  "parameters": {"key": "value"},
  "response": "Natural language response",
  "executable": true/false
}
''';

      final request = ChatGPTRequest(
        model: _defaultModel,
        messages: [
          ChatGPTMessage(
            role: 'system',
            content:
                'You are a smart home assistant that parses commands and returns structured JSON responses.',
          ),
          ChatGPTMessage(role: 'user', content: prompt),
        ],
        temperature: 0.1,
        max_tokens: 200,
      );

      final response = await _dio.post('', data: request.toJson());

      final chatGptResponse = ChatGPTResponse.fromJson(response.data);

      if (chatGptResponse.choices.isEmpty) {
        throw Exception('No response from ChatGPT');
      }

      return chatGptResponse.choices.first.message.content;
    } catch (e) {
      throw Exception('Failed to process smart home command: $e');
    }
  }

  Future<Conversation> _getOrCreateConversation(String conversationId) async {
    final conversationJson = await SecureStorageService.getConversation(
      conversationId,
    );

    if (conversationJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(conversationJson);
        return Conversation.fromJson(json);
      } catch (e) {
        // If parsing fails, create new conversation
        return _createNewConversation(conversationId);
      }
    } else {
      return _createNewConversation(conversationId);
    }
  }

  Future<Conversation> _createNewConversation(String conversationId) async {
    final userId = await SecureStorageService.getUserId();
    return Conversation(
      id: conversationId,
      userId: userId ?? 'unknown',
      messages: [
        ChatGPTMessage(
          role: 'system',
          content:
              'You are a helpful assistant for a Xiaomi Watch S1 Active user. Provide concise, helpful responses suitable for smartwatch display.',
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveConversation(Conversation conversation) async {
    final conversationJson = jsonEncode(conversation.toJson());
    await SecureStorageService.saveConversation(
      conversation.id,
      conversationJson,
    );
  }

  Future<List<Conversation>> getRecentConversations({int limit = 10}) async {
    final conversationIds = await SecureStorageService.getAllConversationIds();
    final conversations = <Conversation>[];

    for (final id in conversationIds.take(limit)) {
      final conversationJson = await SecureStorageService.getConversation(id);
      if (conversationJson != null) {
        try {
          final Map<String, dynamic> json = jsonDecode(conversationJson);
          final conversation = Conversation.fromJson(json);
          conversations.add(conversation);
        } catch (e) {
          // Skip invalid conversations
          continue;
        }
      }
    }

    // Sort by updated date (most recent first)
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  Future<void> clearConversationHistory() async {
    final conversationIds = await SecureStorageService.getAllConversationIds();
    for (final id in conversationIds) {
      await SecureStorageService.deleteConversation(id);
    }
  }
}
