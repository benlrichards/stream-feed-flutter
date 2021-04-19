import 'package:faye_dart/src/channel.dart';
import 'package:faye_dart/src/message.dart';
import 'package:test/test.dart';

main() {
  test('Advice', () {
    final advice = Advice.fromJson({
      'interval': 2,
      'reconnect': '',
      'timeout': 2
    }); //Advice(interval: 2, reconnect: '', timeout: 2);
    expect(advice, Advice(interval: 2, reconnect: '', timeout: 2));
  });

  group('Message', () {
    test('fromJson', () {
      var data = {
        "id": "test",
        "group": "test",
        "activities": [
          {
            "id": "test",
            "actor": "test",
            "verb": "test",
            "object": "test",
            "foreign_id": "test",
            "target": "test",
            "time": "2001-09-11T00:01:02.000",
            "origin": "test",
            "to": ["slug:id"],
            "score": 1.0,
            "analytics": {"test": "test"},
            "extra_context": {"test": "test"},
            "test": "test"
          }
        ],
        "actor_count": 1,
        "created_at": "2001-09-11T00:01:02.000",
        "updated_at": "2001-09-11T00:01:02.000"
      };
      final message = Message.fromJson(
        {'channel': 'bayeuxChannel', 'data': data},
      );
      expect(message,
          Message("bayeuxChannel", channel: Channel(name: "hey"), data: data));
    });

    test('bayeuxChannel equals handshake_channel', () {
      final version = '1.0';
      final minimumVersion = '1.0';
      final supportedConnectionTypes = ['websocket'];
      var channel = Channel(name: "hey");
      final ext = channel.ext;

      final message = Message("/meta/handshake", channel: channel);
      expect(message.version, version);
      expect(message.minimumVersion, minimumVersion);
      expect(message.supportedConnectionTypes, supportedConnectionTypes);
      expect(message.ext, ext);
    });
  });
}
