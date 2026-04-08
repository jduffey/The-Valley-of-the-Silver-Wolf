import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';

class EventLogPanel extends StatelessWidget {
  const EventLogPanel({required this.eventLog, super.key});

  final List<GameLogEntry> eventLog;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Event Log',
      subtitle: 'The newest engine events stay pinned to the top.',
      child: eventLog.isEmpty
          ? const Text('No events yet.')
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: eventLog.length,
                separatorBuilder: (_, _) => const Divider(height: 16),
                itemBuilder: (BuildContext context, int index) {
                  final GameLogEntry entry = eventLog[index];
                  return Text(entry.message);
                },
              ),
            ),
    );
  }
}
