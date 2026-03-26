import 'package:flutter/material.dart';
import '../../../domain/entities/call_entities.dart';

class LogsList extends StatelessWidget {
  final List<BlockedLog> logs;

  const LogsList({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No blocked calls recorded.'),
      ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];

        return Card(
          elevation: 0,
          color: Colors.white.withValues(alpha: 0.05),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.call_end, color: Colors.white),
            ),
            title: Text(log.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(log.reason),
            trailing: Text(
              '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
