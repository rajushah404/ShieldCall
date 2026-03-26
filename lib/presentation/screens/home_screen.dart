import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';
import '../widgets/status_card.dart';
import '../widgets/settings_tile.dart';
import '../widgets/frequency_slider.dart';

import 'logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CallBloc>().add(LoadSettingsAndLogs());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Shield' : 'History',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildSettingsView(context), const LogsScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined, size: 22),
            activeIcon: Icon(Icons.shield, size: 22),
            label: 'Shield',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: 22),
            activeIcon: Icon(Icons.history, size: 22),
            label: 'Logs',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(BuildContext context) {
    return BlocBuilder<CallBloc, CallState>(
      builder: (context, state) {
        if (state is CallLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CallLoaded) {
          final settings = state.settings;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusCard(
                  isActive: settings.isDefaultApp,
                  onRequestSetup: () =>
                      context.read<CallBloc>().add(RequestDefaultAppAction()),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Block Rules',
                  icon: Icons.security,
                  children: [
                    SettingsTile(
                      title: 'Call Screening',
                      subtitle: 'Master toggle for all blocking',
                      value: settings.blockEnabled,
                      onChanged: (val) => context.read<CallBloc>().add(
                        UpdateSetting('blockEnabled', val),
                      ),
                      icon: Icons.power_settings_new,
                    ),
                    SettingsTile(
                      title: 'Extreme Block',
                      subtitle: 'Block every incoming call',
                      value: settings.blockAll,
                      onChanged: (val) => context.read<CallBloc>().add(
                        UpdateSetting('blockAll', val),
                      ),
                      icon: Icons.do_not_disturb_on,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionCard(
                  title: 'Filters',
                  icon: Icons.tune,
                  children: [
                    SettingsTile(
                      title: 'Contacts Only',
                      subtitle: 'Allow only saved contacts',
                      value: settings.whitelistMode,
                      onChanged: (val) => context.read<CallBloc>().add(
                        UpdateSetting('whitelistMode', val),
                      ),
                      icon: Icons.people_outline,
                    ),
                    SettingsTile(
                      title: 'Favorites Only',
                      subtitle: 'Allow only starred contacts',
                      value: settings.focusMode,
                      onChanged: (val) => context.read<CallBloc>().add(
                        UpdateSetting('focusMode', val),
                      ),
                      icon: Icons.star_border,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionCard(
                  title: 'Spam Limit',
                  icon: Icons.timer_outlined,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    FrequencySlider(
                      maxCalls: settings.maxCalls,
                      timeWindow: settings.timeWindow,
                      onMaxCallsChanged: (val) => context.read<CallBloc>().add(
                        UpdateSetting('maxCalls', val),
                      ),
                      onTimeWindowChanged: (val) => context
                          .read<CallBloc>()
                          .add(UpdateSetting('timeWindow', val)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (state is CallError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
