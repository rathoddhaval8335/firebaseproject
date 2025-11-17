import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebaseproject/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'AuthWrapper.dart';
import 'authservice.dart';
import 'home.dart';
import 'login.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Message data: ${message.data}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // If you have firebase_options.dart from flutterfire CLI:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }
  Future<void> _initFCM() async {
    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permission granted for notifications');

      // Get the token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      setState(() => _token = token);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 Received a message while in foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.notification!.title ?? 'New Notification!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('🟢 Message clicked!');
        Navigator.pushNamed(context, '/home');
      });
    } else {
      print('User declined notification permissions');
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Firebase Auth Demo',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: AuthWrapper(),
        routes: {
          '/login': (_) => LoginScreen(),
          '/register': (_) => RegisterScreen(),
          '/home': (_) => HomeScreen(),
        },
      ),
    );
  }
}
