import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'channel.dart';

int _messageId = 0; //TODO: weird, uuid instead?

abstract class _MessageObject {
  static String get id {
    _messageId += 1;
    if (_messageId >= math.pow(2, 32)) _messageId = 0;
    return _messageId.toRadixString(36);
  }
}

class Message with EquatableMixin {
  final String? clientId;
  final String channel;
  final String id;
  String? connectionType;
  String? version;
  String? minimumVersion;
  List<String>? supportedConnectionTypes;
  Advice? advice;
  bool? successful;
  String? subscription;
  Map<String, Object>? ext;
  Map<String, dynamic>? data;
  String? error;

  Message(
    String bayeuxChannel, {
    Channel? channel,
    Map<String, Object>? data,
    this.clientId,
  })  : id = _MessageObject.id,
        channel = bayeuxChannel,
        data = data {
    if (bayeuxChannel == handshake_channel) {
      version = '1.0';
      minimumVersion = '1.0';
      supportedConnectionTypes = ['websocket'];
    } else if (bayeuxChannel == connect_channel) {
      connectionType = 'websocket';
    } else if (bayeuxChannel == subscribe_channel ||
        bayeuxChannel == unsubscribe_channel) {
      subscription = channel?.name;
      ext = channel?.ext;
    }
  }

  Map<String, Object?> toJson() {
    final result = <String, Object?>{};
    if (clientId != null) result['clientId'] = clientId;
    if (data != null) result['data'] = data;
    result['channel'] = channel;
    if (connectionType != null) result['connectionType'] = connectionType;
    if (version != null) result['version'] = version;
    if (minimumVersion != null) result['minimumVersion'] = minimumVersion;
    if (supportedConnectionTypes != null)
      result['supportedConnectionTypes'] = supportedConnectionTypes;
    if (advice != null) result['advice'] = advice;
    if (successful != null) result['successful'] = successful;
    if (subscription != null) result['subscription'] = subscription;
    if (ext != null) result['ext'] = ext;
    if (version != null) result['error'] = error;
    return result;
  }

  @override
  toString() => "${toJson()}";

  factory Message.fromJson(Map<String, Object?> json) {
    final channel = json['channel'] as String;
    final clientId = json['clientId'] as String?;
    final message = Message(channel, clientId: clientId)
      ..version = json['version'] as String?
      ..minimumVersion = json['minimumVersion'] as String?
      ..supportedConnectionTypes = (json['supportedConnectionTypes'] as List?)
          ?.map((e) => e as String)
          .toList()
      ..successful = json['successful'] as bool?
      ..subscription = json['subscription'] as String?
      ..data = json['data'] as Map<String, dynamic>?
      ..ext = json['ext'] as Map<String, Object>?
      ..error = json['error'] as String?;

    final advice = json['advice'];
    if (advice != null) {
      message..advice = Advice.fromJson(advice as Map<String, Object?>);
    }
    return message;
  }

  @override
  List<Object?> get props => [clientId, channel, data]; //, id
}

class Advice extends Equatable {
  Advice({
    required this.reconnect,
    required this.interval,
    this.timeout,
  });

  final String reconnect;
  final int interval;
  final int? timeout;

  static const none = 'none';
  static const handshake = 'handshake';
  static const retry = 'retry';

  factory Advice.fromJson(Map<String, dynamic> json) => Advice(
        reconnect: json["reconnect"] == null ? null : json["reconnect"],
        interval: json["interval"] == null ? null : json["interval"],
        timeout: json["timeout"] == null ? null : json["timeout"],
      );

  Map<String, dynamic> toJson() => {
        "reconnect": reconnect,
        "interval": interval,
        "timeout": timeout == null ? null : timeout,
      };

  @override
  List<Object?> get props => [
        reconnect,
        interval,
        timeout,
      ];
}