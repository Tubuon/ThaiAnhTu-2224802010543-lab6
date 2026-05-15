import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final audioProvider = context.watch<AudioProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Settings',
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.dark_mode, color: AppColors.icon(context)),
          title: Text(
            'Dark Mode',
            style: TextStyle(color: AppColors.text(context)),
          ),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            activeThumbColor: const Color(0xFF1DB954),
            activeTrackColor: const Color(0xFF1DB954).withValues(alpha: 0.5),
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
        ),
        const Divider(color: Colors.grey),
        ListTile(
          leading: Icon(Icons.volume_up, color: AppColors.icon(context)),
          title: Text('Volume', style: TextStyle(color: AppColors.text(context))),
          subtitle: Slider(
            value: audioProvider.volume,
            min: 0,
            max: 1,
            activeColor: const Color(0xFF1DB954),
            onChanged: audioProvider.setVolume,
          ),
          trailing: Text(
            '${(audioProvider.volume * 100).round()}%',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ListTile(
          leading: Icon(Icons.speed, color: AppColors.icon(context)),
          title: Text(
            'Playback Speed',
            style: TextStyle(color: AppColors.text(context)),
          ),
          subtitle: Slider(
            value: audioProvider.speed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            activeColor: const Color(0xFF1DB954),
            onChanged: audioProvider.setSpeed,
          ),
          trailing: Text(
            '${audioProvider.speed.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ListTile(
          leading: Icon(Icons.bedtime, color: AppColors.icon(context)),
          title: Text('Sleep Timer', style: TextStyle(color: AppColors.text(context))),
          subtitle: Text(
            audioProvider.sleepTimerRemaining == null
                ? 'Off'
                : _formatRemaining(audioProvider.sleepTimerRemaining!),
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            color: const Color(0xFF282828),
            onSelected: (minutes) {
              if (minutes == 0) {
                audioProvider.cancelSleepTimer();
              } else {
                audioProvider.startSleepTimer(Duration(minutes: minutes));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 5,
                child: Text('5 minutes', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: 15,
                child: Text('15 minutes', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: 30,
                child: Text('30 minutes', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: 0,
                child: Text('Cancel timer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey),
        ListTile(
          leading: Icon(Icons.info_outline, color: AppColors.icon(context)),
          title: Text('Version', style: TextStyle(color: AppColors.text(context))),
          trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
        ),
        const Divider(color: Colors.grey),
        ListTile(
          leading: Icon(Icons.music_note, color: AppColors.icon(context)),
          title: Text('Offline Music Player',
              style: TextStyle(color: AppColors.text(context))),
          subtitle: const Text('Built with Flutter & just_audio',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds remaining';
  }
}
