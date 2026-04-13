import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();

  String statusText = 'Waiting for a cloud message';
  String imagePath = 'assets/images/default.webp';
  String tokenText = 'Loading token...';

  @override
  void initState() {
    super.initState();

    _fcmService.initialize(
      onData: (RemoteMessage message) {
        final assetName = message.data['asset'];
        debugPrint('Raw asset value: $assetName');
        debugPrint(
          'Trying to load: assets/images/${assetName != null && assetName.toString().isNotEmpty ? assetName : 'default'}.webp',
        );

        setState(() {
          statusText = message.notification?.title ?? 'Payload received';

          final assetName = message.data['asset'];
          if (assetName != null && assetName.toString().isNotEmpty) {
            imagePath = 'assets/images/$assetName.webp';
          } else {
            imagePath = 'assets/images/default.webp';
          }
        });

        debugPrint('Notification title: ${message.notification?.title}');
        debugPrint('Message data: ${message.data}');
      },
    );

    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _fcmService.getToken();
    setState(() {
      tokenText = token ?? 'No token available';
    });
    debugPrint('FCM token: $token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 14 FCM Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              statusText,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Image could not be loaded'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'FCM Token:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(tokenText),
          ],
        ),
      ),
    );
  }
}