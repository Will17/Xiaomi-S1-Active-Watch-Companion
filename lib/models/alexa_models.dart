import 'package:json_annotation/json_annotation.dart';

part 'alexa_models.g.dart';

@JsonSerializable()
class AlexaRequest {
  final String version;
  final AlexaRequestContext context;
  final AlexaRequestData request;

  AlexaRequest({
    required this.version,
    required this.context,
    required this.request,
  });

  factory AlexaRequest.fromJson(Map<String, dynamic> json) =>
      _$AlexaRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaRequestToJson(this);
}

@JsonSerializable()
class AlexaRequestContext {
  final AlexaContextSystem System;

  AlexaRequestContext({required this.System});

  factory AlexaRequestContext.fromJson(Map<String, dynamic> json) =>
      _$AlexaRequestContextFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaRequestContextToJson(this);
}

@JsonSerializable()
class AlexaContextSystem {
  final AlexaSystemApplication application;
  final AlexaSystemUser user;
  final AlexaSystemDevice device;

  AlexaContextSystem({
    required this.application,
    required this.user,
    required this.device,
  });

  factory AlexaContextSystem.fromJson(Map<String, dynamic> json) =>
      _$AlexaContextSystemFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaContextSystemToJson(this);
}

@JsonSerializable()
class AlexaSystemApplication {
  final String applicationId;

  AlexaSystemApplication({required this.applicationId});

  factory AlexaSystemApplication.fromJson(Map<String, dynamic> json) =>
      _$AlexaSystemApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaSystemApplicationToJson(this);
}

@JsonSerializable()
class AlexaSystemUser {
  final String userId;

  AlexaSystemUser({required this.userId});

  factory AlexaSystemUser.fromJson(Map<String, dynamic> json) =>
      _$AlexaSystemUserFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaSystemUserToJson(this);
}

@JsonSerializable()
class AlexaSystemDevice {
  final String deviceId;
  final List<String> supportedInterfaces;

  AlexaSystemDevice({
    required this.deviceId,
    required this.supportedInterfaces,
  });

  factory AlexaSystemDevice.fromJson(Map<String, dynamic> json) =>
      _$AlexaSystemDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaSystemDeviceToJson(this);
}

@JsonSerializable()
class AlexaRequestData {
  final String type;
  final String requestId;
  final DateTime timestamp;
  final AlexaIntent intent;
  final Map<String, dynamic>? locale;

  AlexaRequestData({
    required this.type,
    required this.requestId,
    required this.timestamp,
    required this.intent,
    this.locale,
  });

  factory AlexaRequestData.fromJson(Map<String, dynamic> json) =>
      _$AlexaRequestDataFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaRequestDataToJson(this);
}

@JsonSerializable()
class AlexaIntent {
  final String name;
  final Map<String, dynamic>? slots;

  AlexaIntent({required this.name, this.slots});

  factory AlexaIntent.fromJson(Map<String, dynamic> json) =>
      _$AlexaIntentFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaIntentToJson(this);
}

@JsonSerializable()
class AlexaWebhookPayload {
  final String voice_input;
  final String intent;
  final Map<String, dynamic>? slots;
  final String user_id;
  final String device_id;
  final DateTime timestamp;

  AlexaWebhookPayload({
    required this.voice_input,
    required this.intent,
    this.slots,
    required this.user_id,
    required this.device_id,
    required this.timestamp,
  });

  factory AlexaWebhookPayload.fromJson(Map<String, dynamic> json) =>
      _$AlexaWebhookPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaWebhookPayloadToJson(this);
}

@JsonSerializable()
class AlexaResponse {
  final String version;
  final AlexaResponseSession sessionAttributes;
  final AlexaResponseResponse response;

  AlexaResponse({
    required this.version,
    required this.sessionAttributes,
    required this.response,
  });

  factory AlexaResponse.fromJson(Map<String, dynamic> json) =>
      _$AlexaResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaResponseToJson(this);
}

@JsonSerializable()
class AlexaResponseSession {
  final Map<String, dynamic> attributes;

  AlexaResponseSession({required this.attributes});

  factory AlexaResponseSession.fromJson(Map<String, dynamic> json) =>
      _$AlexaResponseSessionFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaResponseSessionToJson(this);
}

@JsonSerializable()
class AlexaResponseResponse {
  final AlexaResponseOutputSpeech outputSpeech;
  final AlexaResponseCard? card;
  final bool shouldEndSession;

  AlexaResponseResponse({
    required this.outputSpeech,
    this.card,
    required this.shouldEndSession,
  });

  factory AlexaResponseResponse.fromJson(Map<String, dynamic> json) =>
      _$AlexaResponseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaResponseResponseToJson(this);
}

@JsonSerializable()
class AlexaResponseOutputSpeech {
  final String type;
  final String text;

  AlexaResponseOutputSpeech({required this.type, required this.text});

  factory AlexaResponseOutputSpeech.fromJson(Map<String, dynamic> json) =>
      _$AlexaResponseOutputSpeechFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaResponseOutputSpeechToJson(this);
}

@JsonSerializable()
class AlexaResponseCard {
  final String type;
  final String title;
  final String content;

  AlexaResponseCard({
    required this.type,
    required this.title,
    required this.content,
  });

  factory AlexaResponseCard.fromJson(Map<String, dynamic> json) =>
      _$AlexaResponseCardFromJson(json);
  Map<String, dynamic> toJson() => _$AlexaResponseCardToJson(this);
}
