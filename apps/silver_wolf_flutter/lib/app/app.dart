import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';

class SilverWolfApp extends StatelessWidget {
  const SilverWolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valley of the Silver Wolf',
      home: Scaffold(
        appBar: AppBar(title: const Text('Valley of the Silver Wolf')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Workspace bootstrap complete'),
              SizedBox(height: 8),
              Text(workspaceReadyMessage),
            ],
          ),
        ),
      ),
    );
  }
}
