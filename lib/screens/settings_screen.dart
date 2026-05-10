import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode, color: Colors.white),
          title: const Text(
            'Dark Mode',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            activeThumbColor: const Color(0xFF1DB954),
            activeTrackColor: const Color(0xFF1DB954).withValues(alpha: 0.5),
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
        ),
        const Divider(color: Colors.grey),
        const ListTile(
          leading: Icon(Icons.info_outline, color: Colors.white),
          title: Text('Version', style: TextStyle(color: Colors.white)),
          trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
        ),
        const Divider(color: Colors.grey),
        const ListTile(
          leading: Icon(Icons.music_note, color: Colors.white),
          title: Text('Offline Music Player',
              style: TextStyle(color: Colors.white)),
          subtitle: Text('Built with Flutter & just_audio',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }
}