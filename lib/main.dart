import 'package:flutter/material.dart';
import 'package:saracoglu_mobil/views/main_screen.dart';
import 'package:saracoglu_mobil/theme/app_theme.dart';
import 'package:saracoglu_mobil/services/auth_service.dart';

/// Global Navigator Key - 403 hatası için login sayfasına yönlendirme
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        home: const MainScreen(),
      ),
    );
  }
}
