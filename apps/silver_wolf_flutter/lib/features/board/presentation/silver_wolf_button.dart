import 'package:flutter/material.dart';

class SilverWolfButton extends StatelessWidget {
  const SilverWolfButton({
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(28),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.pets),
          SizedBox(height: 6),
          Text('Silver Wolf'),
        ],
      ),
    );
  }
}
