import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool isActive;
  final VoidCallback onRequestSetup;

  const StatusCard({
    super.key,
    required this.isActive,
    required this.onRequestSetup,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isActive 
              ? [Colors.deepPurple, Colors.indigo] 
              : [Colors.redAccent, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.verified_user : Icons.warning_amber_rounded,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Active Protection' : 'Protection Paused',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    isActive 
                      ? 'App screening is active.' 
                      : 'Grant setup to start blocking.',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (!isActive)
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onRequestSetup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text('Setup', style: TextStyle(fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
