// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatgpt_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatGPTRequest _$ChatGPTRequestFromJson(Map<String, dynamic> json) =>
    ChatGPTRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatGPTMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      max_tokens: (json['max_tokens'] as num?)?.toInt(),
      top_p: (json['top_p'] as num?)?.toDouble(),
      frequency_penalty: json['frequency_penalty'] as String?,
      presence_penalty: json['presence_penalty'] as String?,
    );

Map<String, dynamic> _$ChatGPTRequestToJson(ChatGPTRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'temperature': instance.temperature,
      'max_tokens': instance.max_tokens,
      'top_p': instance.top_p,
      'frequency_penalty': instance.frequency_penalty,
      'presence_penalty': instance.presence_penalty,
    };

ChatGPTMessage _$ChatGPTMessageFromJson(Map<String, dynamic> json) =>
    ChatGPTMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ChatGPTMessageToJson(ChatGPTMessage instance) =>
    <String, dynamic>{'role': instance.role, 'content': instance.content};

ChatGPTResponse _$ChatGPTResponseFromJson(Map<String, dynamic> json) =>
    ChatGPTResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: DateTime.parse(json['created'] as String),
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => ChatGPTChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: ChatGPTUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatGPTResponseToJson(ChatGPTResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created.toIso8601String(),
      'model': instance.model,
      'choices': instance.choices,
      'usage': instance.usage,
    };

ChatGPTChoice _$ChatGPTChoiceFromJson(Map<String, dynamic> json) =>
    ChatGPTChoice(
      index: (json['index'] as num).toInt(),
      message: ChatGPTMessage.fromJson(json['message'] as Map<String, dynamic>),
      finish_reason: json['finish_reason'] as String,
    );

Map<String, dynamic> _$ChatGPTChoiceToJson(ChatGPTChoice instance) =>
    <String, dynamic>{
      'index': instance.index,
      'message': instance.message,
      'finish_reason': instance.finish_reason,
    };

ChatGPTUsage _$ChatGPTUsageFromJson(Map<String, dynamic> json) => ChatGPTUsage(
  prompt_tokens: (json['prompt_tokens'] as num).toInt(),
  completion_tokens: (json['completion_tokens'] as num).toInt(),
  total_tokens: (json['total_tokens'] as num).toInt(),
);

Map<String, dynamic> _$ChatGPTUsageToJson(ChatGPTUsage instance) =>
    <String, dynamic>{
      'prompt_tokens': instance.prompt_tokens,
      'completion_tokens': instance.completion_tokens,
      'total_tokens': instance.total_tokens,
    };

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: json['id'] as String,
  userId: json['userId'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => ChatGPTMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'messages': instance.messages,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

IntentType _$IntentTypeFromJson(Map<String, dynamic> json) => IntentType();

Map<String, dynamic> _$IntentTypeToJson(IntentType instance) =>
    <String, dynamic>{};

AutomationCommand _$AutomationCommandFromJson(Map<String, dynamic> json) =>
    AutomationCommand(
      id: json['id'] as String,
      type: json['type'] as String,
      command: json['command'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      executed: json['executed'] as bool,
    );

Map<String, dynamic> _$AutomationCommandToJson(AutomationCommand instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'command': instance.command,
      'parameters': instance.parameters,
      'timestamp': instance.timestamp.toIso8601String(),
      'executed': instance.executed,
    };
