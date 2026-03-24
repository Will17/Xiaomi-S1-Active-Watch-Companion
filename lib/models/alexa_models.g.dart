// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alexa_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlexaRequest _$AlexaRequestFromJson(Map<String, dynamic> json) => AlexaRequest(
  version: json['version'] as String,
  context: AlexaRequestContext.fromJson(
    json['context'] as Map<String, dynamic>,
  ),
  request: AlexaRequestData.fromJson(json['request'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AlexaRequestToJson(AlexaRequest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'context': instance.context,
      'request': instance.request,
    };

AlexaRequestContext _$AlexaRequestContextFromJson(Map<String, dynamic> json) =>
    AlexaRequestContext(
      System: AlexaContextSystem.fromJson(
        json['System'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AlexaRequestContextToJson(
  AlexaRequestContext instance,
) => <String, dynamic>{'System': instance.System};

AlexaContextSystem _$AlexaContextSystemFromJson(Map<String, dynamic> json) =>
    AlexaContextSystem(
      application: AlexaSystemApplication.fromJson(
        json['application'] as Map<String, dynamic>,
      ),
      user: AlexaSystemUser.fromJson(json['user'] as Map<String, dynamic>),
      device: AlexaSystemDevice.fromJson(
        json['device'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AlexaContextSystemToJson(AlexaContextSystem instance) =>
    <String, dynamic>{
      'application': instance.application,
      'user': instance.user,
      'device': instance.device,
    };

AlexaSystemApplication _$AlexaSystemApplicationFromJson(
  Map<String, dynamic> json,
) => AlexaSystemApplication(applicationId: json['applicationId'] as String);

Map<String, dynamic> _$AlexaSystemApplicationToJson(
  AlexaSystemApplication instance,
) => <String, dynamic>{'applicationId': instance.applicationId};

AlexaSystemUser _$AlexaSystemUserFromJson(Map<String, dynamic> json) =>
    AlexaSystemUser(userId: json['userId'] as String);

Map<String, dynamic> _$AlexaSystemUserToJson(AlexaSystemUser instance) =>
    <String, dynamic>{'userId': instance.userId};

AlexaSystemDevice _$AlexaSystemDeviceFromJson(Map<String, dynamic> json) =>
    AlexaSystemDevice(
      deviceId: json['deviceId'] as String,
      supportedInterfaces: (json['supportedInterfaces'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AlexaSystemDeviceToJson(AlexaSystemDevice instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'supportedInterfaces': instance.supportedInterfaces,
    };

AlexaRequestData _$AlexaRequestDataFromJson(Map<String, dynamic> json) =>
    AlexaRequestData(
      type: json['type'] as String,
      requestId: json['requestId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      intent: AlexaIntent.fromJson(json['intent'] as Map<String, dynamic>),
      locale: json['locale'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AlexaRequestDataToJson(AlexaRequestData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'requestId': instance.requestId,
      'timestamp': instance.timestamp.toIso8601String(),
      'intent': instance.intent,
      'locale': instance.locale,
    };

AlexaIntent _$AlexaIntentFromJson(Map<String, dynamic> json) => AlexaIntent(
  name: json['name'] as String,
  slots: json['slots'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AlexaIntentToJson(AlexaIntent instance) =>
    <String, dynamic>{'name': instance.name, 'slots': instance.slots};

AlexaWebhookPayload _$AlexaWebhookPayloadFromJson(Map<String, dynamic> json) =>
    AlexaWebhookPayload(
      voice_input: json['voice_input'] as String,
      intent: json['intent'] as String,
      slots: json['slots'] as Map<String, dynamic>?,
      user_id: json['user_id'] as String,
      device_id: json['device_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$AlexaWebhookPayloadToJson(
  AlexaWebhookPayload instance,
) => <String, dynamic>{
  'voice_input': instance.voice_input,
  'intent': instance.intent,
  'slots': instance.slots,
  'user_id': instance.user_id,
  'device_id': instance.device_id,
  'timestamp': instance.timestamp.toIso8601String(),
};

AlexaResponse _$AlexaResponseFromJson(Map<String, dynamic> json) =>
    AlexaResponse(
      version: json['version'] as String,
      sessionAttributes: AlexaResponseSession.fromJson(
        json['sessionAttributes'] as Map<String, dynamic>,
      ),
      response: AlexaResponseResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AlexaResponseToJson(AlexaResponse instance) =>
    <String, dynamic>{
      'version': instance.version,
      'sessionAttributes': instance.sessionAttributes,
      'response': instance.response,
    };

AlexaResponseSession _$AlexaResponseSessionFromJson(
  Map<String, dynamic> json,
) => AlexaResponseSession(
  attributes: json['attributes'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AlexaResponseSessionToJson(
  AlexaResponseSession instance,
) => <String, dynamic>{'attributes': instance.attributes};

AlexaResponseResponse _$AlexaResponseResponseFromJson(
  Map<String, dynamic> json,
) => AlexaResponseResponse(
  outputSpeech: AlexaResponseOutputSpeech.fromJson(
    json['outputSpeech'] as Map<String, dynamic>,
  ),
  card: json['card'] == null
      ? null
      : AlexaResponseCard.fromJson(json['card'] as Map<String, dynamic>),
  shouldEndSession: json['shouldEndSession'] as bool,
);

Map<String, dynamic> _$AlexaResponseResponseToJson(
  AlexaResponseResponse instance,
) => <String, dynamic>{
  'outputSpeech': instance.outputSpeech,
  'card': instance.card,
  'shouldEndSession': instance.shouldEndSession,
};

AlexaResponseOutputSpeech _$AlexaResponseOutputSpeechFromJson(
  Map<String, dynamic> json,
) => AlexaResponseOutputSpeech(
  type: json['type'] as String,
  text: json['text'] as String,
);

Map<String, dynamic> _$AlexaResponseOutputSpeechToJson(
  AlexaResponseOutputSpeech instance,
) => <String, dynamic>{'type': instance.type, 'text': instance.text};

AlexaResponseCard _$AlexaResponseCardFromJson(Map<String, dynamic> json) =>
    AlexaResponseCard(
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$AlexaResponseCardToJson(AlexaResponseCard instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
    };
