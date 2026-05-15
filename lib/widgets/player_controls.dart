import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: provider.isShuffleEnabled
                    ? const Color(0xFF1DB954)
                    : Colors.grey,
                size: 28,
              ),
              onPressed: () => provider.toggleShuffle(),
            ),
            const SizedBox(width: 60),
            _buildRepeatButton(),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.skip_previous,
                color: AppColors.icon(context),
                size: 40,
              ),
              onPressed: () => provider.previous(),
            ),

            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return GestureDetector(
                  onTap: () => provider.playPause(),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1DB954),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),

            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: AppColors.icon(context),
                size: 40,
              ),
              onPressed: () => provider.next(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepeatButton() {
    IconData icon;
    Color color;

    switch (provider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = Colors.grey;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = const Color(0xFF1DB954);
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = const Color(0xFF1DB954);
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color, size: 28),
      onPressed: () => provider.toggleRepeat(),
    );
  }
}
