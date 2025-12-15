import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:saracoglu_mobil/views/main_screen.dart';
import 'package:saracoglu_mobil/views/notifications_page.dart';
import 'package:saracoglu_mobil/theme/app_theme.dart';
import 'package:saracoglu_mobil/services/auth_service.dart';
import 'package:saracoglu_mobil/services/firebase_messaging_service.dart';
import 'firebase_options.dart';

/// Global Navigator Key - 403 hatası için login sayfasına yönlendirme
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingService.initialize();

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // AuthService'i initialize et (kaydedilmiş oturumu kontrol et)
  AuthService.navigatorKey = navigatorKey;
  final authService = AuthService();
  await authService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Herhangi bir yere dokunulduğunda klavyeyi kapat
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Saraçoğlu',
        debugShowCheckedModeBanner: false,
        theme: getAppTheme(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(boldText: false),
            child: child!,
          );
        },
        home: UpgradeAlert(child: const MainScreen()),
        routes: {'/notifications': (context) => const NotificationsPage()},
      ),
    );
  }
}
