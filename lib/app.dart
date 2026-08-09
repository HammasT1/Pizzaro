import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/home/home_screen.dart';

class PizzaroApp extends StatelessWidget {
  const PizzaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizzaro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
