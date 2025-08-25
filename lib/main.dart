import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 Mensaje en segundo plano: ${message.messageId}");
}

void getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  debugPrint("📲 Token del dispositivo: $token");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Notificaciones Básicas',
      channelDescription: 'Canal para notificaciones generales',
      importance: NotificationImportance.Max,
    ),
  ]);

  AwesomeNotifications().isNotificationAllowed().then((allowed) {
    if (!allowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Listener para mensajes en primer plano (debug)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint(
      '🔔 Mensaje recibido en primer plano: ${message.notification?.title} - ${message.notification?.body}',
    );
  });

  getToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagos QR',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(129, 167, 34, 255),
        ),
      ),
      home: AuthScreen(), // Pantalla de autenticación como inicial
      routes: {'/home': (context) => Placeholder()},
      navigatorObservers: [routeObserver],
    );
  }
}
