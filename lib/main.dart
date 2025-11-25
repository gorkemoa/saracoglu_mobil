import 'package:flutter/material.dart';
import 'package:saracoglu_mobil/views/homepage_views.dart';
import 'package:saracoglu_mobil/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saraçoğlu',
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
      home: const HomePage(),
    );
  }
}
