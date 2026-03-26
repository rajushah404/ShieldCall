import 'package:flutter/material.dart';

class FrequencySlider extends StatelessWidget {
  final int maxCalls;
  final int timeWindow;
  final ValueChanged<int> onMaxCallsChanged;
  final ValueChanged<int> onTimeWindowChanged;

  const FrequencySlider({
    super.key,
    required this.maxCalls,
    required this.timeWindow,
    required this.onMaxCallsChanged,
    required this.onTimeWindowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Reject if number calls more than X times')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: maxCalls.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$maxCalls times',
                    onChanged: (val) => onMaxCallsChanged(val.toInt()),
                  ),
                ),
                Text('$maxCalls calls', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Within a window of')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: timeWindow.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '$timeWindow mins',
                    onChanged: (val) => onTimeWindowChanged(val.toInt()),
                  ),
                ),
                Text('$timeWindow mins', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
