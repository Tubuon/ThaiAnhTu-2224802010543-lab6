import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart';
import '../screens/now_playing_screen.dart';
import '../utils/constants.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3), // sửa withOpacity
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<AudioProvider>(
          builder: (context, provider, child) {
            final song = provider.currentSong;

            if (song == null) return const SizedBox.shrink();

            return Column(
              children: [
                // Progress indicator
                StreamBuilder<AudioPlaybackState>(
                  stream: provider.playbackStateStream,
                  builder: (context, snapshot) {
                    final progress = snapshot.data?.progress ?? 0.0;
                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1DB954),
                      ),
                      minHeight: 2,
                    );
                  },
                ),

                // Player content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Album art
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[800],
                          ),
                          child: song.albumArt != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(song.albumArt!),
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(
                            Icons.music_note,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: TextStyle(
                                  color: AppColors.text(context),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Play/Pause button
                        StreamBuilder<bool>(
                          stream: provider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppColors.icon(context),
                                size: 32,
                              ),
                              onPressed: () => provider.playPause(),
                            );
                          },
                        ),

                        // Previous button
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            color: AppColors.icon(context),
                          ),
                          onPressed: () => provider.previous(),
                        ),

                        // Next button
                        IconButton(
                          icon: Icon(
                            Icons.skip_next,
                            color: AppColors.icon(context),
                          ),
                          onPressed: () => provider.next(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
