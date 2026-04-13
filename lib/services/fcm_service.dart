import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize({
    required void Function(RemoteMessage message) onData,
  }) async {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onData(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onData(message);
    });

    final RemoteMessage? initialMessage =
        await messaging.getInitialMessage();

    if (initialMessage != null) {
      onData(initialMessage);
    }
  }

  Future<String?> getToken() {
    return messaging.getToken();
  }
}