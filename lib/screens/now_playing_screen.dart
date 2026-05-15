import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart'; // AudioPlaybackState
import '../utils/constants.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart' as pb;

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: AppColors.text(context)),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        _buildAlbumArt(context, song),
                        const SizedBox(height: 24),
                        _buildSongInfo(context, song),
                        const SizedBox(height: 24),
                        StreamBuilder<AudioPlaybackState>(
                          stream: provider.playbackStateStream,
                          builder: (context, snapshot) {
                            final state = snapshot.data;
                            return pb.ProgressBar(
                              position: state?.position ?? Duration.zero,
                              duration: state?.duration ?? Duration.zero,
                              onSeek: (position) => provider.seek(position),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        PlayerControls(provider: provider),
                        const SizedBox(height: 16),
                        _buildVolumeControl(provider),
                        _buildSpeedControl(context, provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.icon(context),
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Now Playing',
            style: TextStyle(color: AppColors.text(context), fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.icon(context)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, SongModel song) {
    final size = math.min(MediaQuery.sizeOf(context).width - 96, 240.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5), // sửa withOpacity
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.albumArt != null
            ? Image.file(File(song.albumArt!), fit: BoxFit.cover)
            : Container(
          color: AppColors.tile(context),
          child: const Icon(
            Icons.music_note,
            size: 100,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, SongModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: TextStyle(
            color: AppColors.text(context),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          style: TextStyle(color: AppColors.mutedText(context), fontSize: 16),
          textAlign: TextAlign.center,
        ),
        if (song.album != null)
          Text(
            song.album!,
            style: TextStyle(color: AppColors.mutedText(context), fontSize: 13),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildVolumeControl(AudioProvider provider) {
    return Row(
      children: [
        const Icon(Icons.volume_down, color: Colors.grey),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: const Color(0xFF1DB954),
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: provider.volume,
              min: 0.0,
              max: 1.0,
              onChanged: (value) => provider.setVolume(value),
            ),
          ),
        ),
        const Icon(Icons.volume_up, color: Colors.grey),
      ],
    );
  }

  Widget _buildSpeedControl(BuildContext context, AudioProvider provider) {
    return Row(
      children: [
        const Icon(Icons.speed, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          '${provider.speed.toStringAsFixed(1)}x',
          style: TextStyle(color: AppColors.text(context), fontSize: 14),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: const Color(0xFF1DB954),
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: provider.speed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              onChanged: (value) => provider.setSpeed(value),
            ),
          ),
        ),
      ],
    );
  }
}
