import 'package:json_annotation/json_annotation.dart';

part 'chatgpt_models.g.dart';

@JsonSerializable()
class ChatGPTRequest {
  final String model;
  final List<ChatGPTMessage> messages;
  final double? temperature;
  final int? max_tokens;
  final double? top_p;
  final String? frequency_penalty;
  final String? presence_penalty;

  ChatGPTRequest({
    required this.model,
    required this.messages,
    this.temperature,
    this.max_tokens,
    this.top_p,
    this.frequency_penalty,
    this.presence_penalty,
  });

  factory ChatGPTRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatGPTRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChatGPTRequestToJson(this);
}

@JsonSerializable()
class ChatGPTMessage {
  final String role;
  final String content;

  ChatGPTMessage({
    required this.role,
    required this.content,
  });

  factory ChatGPTMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatGPTMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatGPTMessageToJson(this);
}

@JsonSerializable()
class ChatGPTResponse {
  final String id;
  final String object;
  final DateTime created;
  final String model;
  final List<ChatGPTChoice> choices;
  final ChatGPTUsage usage;

  ChatGPTResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory ChatGPTResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatGPTResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatGPTResponseToJson(this);
}

@JsonSerializable()
class ChatGPTChoice {
  final int index;
  final ChatGPTMessage message;
  final String finish_reason;

  ChatGPTChoice({
    required this.index,
    required this.message,
    required this.finish_reason,
  });

  factory ChatGPTChoice.fromJson(Map<String, dynamic> json) =>
      _$ChatGPTChoiceFromJson(json);
  Map<String, dynamic> toJson() => _$ChatGPTChoiceToJson(this);
}

@JsonSerializable()
class ChatGPTUsage {
  final int prompt_tokens;
  final int completion_tokens;
  final int total_tokens;

  ChatGPTUsage({
    required this.prompt_tokens,
    required this.completion_tokens,
    required this.total_tokens,
  });

  factory ChatGPTUsage.fromJson(Map<String, dynamic> json) =>
      _$ChatGPTUsageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatGPTUsageToJson(this);
}

@JsonSerializable()
class Conversation {
  final String id;
  final String userId;
  final List<ChatGPTMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  Conversation copyWith({
    String? id,
    String? userId,
    List<ChatGPTMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class IntentType {
  static const String chatGPTQuery = 'ChatGPTQuery';
  static const String summarizeText = 'SummarizeText';
  static const String smartHomeCommand = 'SmartHomeCommand';
  static const String setReminder = 'SetReminder';
  static const String setTimer = 'SetTimer';
  static const String getWeather = 'GetWeather';
  static const String sendNotification = 'SendNotification';
}

@JsonSerializable()
class AutomationCommand {
  final String id;
  final String type;
  final String command;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;
  final bool executed;

  AutomationCommand({
    required this.id,
    required this.type,
    required this.command,
    this.parameters,
    required this.timestamp,
    required this.executed,
  });

  factory AutomationCommand.fromJson(Map<String, dynamic> json) =>
      _$AutomationCommandFromJson(json);
  Map<String, dynamic> toJson() => _$AutomationCommandToJson(this);
}
