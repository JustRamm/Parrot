import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() {
  runApp(const EchoSignApp());
}

class EchoSignApp extends StatelessWidget {
  const EchoSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EchoSign',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
