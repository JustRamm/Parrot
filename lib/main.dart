import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() {
  runApp(const ParrotApp());
}

class ParrotApp extends StatelessWidget {
  const ParrotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parrot',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
