import 'package:flutter/material.dart';
import 'package:silver_wolf_flutter/core/theme/app_theme.dart';
import 'package:silver_wolf_flutter/features/game_session/presentation/game_shell_page.dart';

class SilverWolfApp extends StatelessWidget {
  const SilverWolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valley of the Silver Wolf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const GameShellPage(),
    );
  }
}
