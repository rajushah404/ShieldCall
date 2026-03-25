import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CallRejecterApp());
}

class CallRejecterApp extends StatelessWidget {
  const CallRejecterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Rejecter Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6200EE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.example.call_rejecter/call_screening');

  bool blockEnabled = false;
  bool whitelistMode = false;
  bool focusMode = false;
  int maxCalls = 3;
  int timeWindow = 5;
  bool isDefaultApp = false;
  List<String> blockedLogs = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermissions();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      blockEnabled = prefs.getBool('blockEnabled') ?? false;
      whitelistMode = prefs.getBool('whitelistMode') ?? false;
      focusMode = prefs.getBool('focusMode') ?? false;
      maxCalls = prefs.getInt('maxCalls') ?? 3;
      timeWindow = prefs.getInt('timeWindow') ?? 5;
      blockedLogs = (prefs.getString('blockedLogs') ?? '').split('\n').where((s) => s.isNotEmpty).toList();
    });
    _checkDefaultAppStatus();
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.phone,
      Permission.contacts,
    ].request();
  }

  Future<void> _checkDefaultAppStatus() async {
    try {
      final bool status = await platform.invokeMethod('isDefaultApp');
      setState(() {
        isDefaultApp = status;
      });
    } on PlatformException catch (e) {
      print("Failed to get status: '${e.message}'.");
    }
  }

  Future<void> _requestDefaultApp() async {
    try {
      await platform.invokeMethod('requestDefaultApp');
      // Status will be updated in next check or on resume
      Future.delayed(const Duration(seconds: 2), _checkDefaultAppStatus);
    } on PlatformException catch (e) {
      print("Failed to request: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Rejecter Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildSectionHeader('General Settings'),
            _buildSettingTile(
              title: 'Enable Call Blocking',
              subtitle: 'Automatically screen and reject calls',
              value: blockEnabled,
              onChanged: (val) {
                setState(() => blockEnabled = val);
                _saveSetting('blockEnabled', val);
              },
              icon: Icons.block,
            ),
            const SizedBox(height: 10),
            _buildSectionHeader('Filtering Modes'),
            _buildSettingTile(
              title: 'Whitelist Mode',
              subtitle: 'Allow only saved contacts',
              value: whitelistMode,
              onChanged: (val) {
                setState(() => whitelistMode = val);
                _saveSetting('whitelistMode', val);
              },
              icon: Icons.contact_phone,
            ),
            _buildSettingTile(
              title: 'Focus Mode',
              subtitle: 'Allow only starred contacts',
              value: focusMode,
              onChanged: (val) {
                setState(() => focusMode = val);
                _saveSetting('focusMode', val);
              },
              icon: Icons.star,
            ),
            const SizedBox(height: 10),
            _buildSectionHeader('Spam Frequency Protection'),
            _buildFrequencySettings(),
            const SizedBox(height: 20),
            _buildSectionHeader('Blocked Call Logs'),
            _buildLogsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDefaultApp 
              ? [Colors.deepPurple, Colors.indigo] 
              : [Colors.redAccent, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isDefaultApp ? Icons.verified_user : Icons.warning_amber_rounded,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDefaultApp ? 'Service Active' : 'Service Inactive',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    isDefaultApp 
                      ? 'The app is set as default call screening service.' 
                      : 'Grant default app status to enable features.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (!isDefaultApp)
              ElevatedButton(
                onPressed: _requestDefaultApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                ),
                child: const Text('Setup'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFrequencySettings() {
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
                    onChanged: (val) {
                      setState(() => maxCalls = val.toInt());
                      _saveSetting('maxCalls', val.toInt());
                    },
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
                    onChanged: (val) {
                      setState(() => timeWindow = val.toInt());
                      _saveSetting('timeWindow', val.toInt());
                    },
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

  Widget _buildLogsList() {
    if (blockedLogs.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No blocked calls recorded.'),
      ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blockedLogs.length,
      itemBuilder: (context, index) {
        final parts = blockedLogs[index].split('|');
        if (parts.length < 3) return const SizedBox();
        final timestamp = DateTime.fromMillisecondsSinceEpoch(int.tryParse(parts[0]) ?? 0);
        final number = parts[1];
        final reason = parts[2];

        return Card(
          elevation: 0,
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.call_end, color: Colors.white),
            ),
            title: Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(reason),
            trailing: Text(
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
