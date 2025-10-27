// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/poem_provider.dart';
import 'screens/poem_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PoemProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6A5ACD)); // magic-ish theme
    return MaterialApp(
      title: 'Poetic Songs',
      theme: ThemeData(colorScheme: scheme, useMaterial3: true),
      home: const PoemListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
