import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class AllSongsScreen extends StatelessWidget {
  final List<SongModel> songs;

  const AllSongsScreen({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'All Songs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: songs.isEmpty
              ? const Center(
            child: Text(
              'No songs found',
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return SongTile(
                song: songs[index],
                onTap: () {
                  context
                      .read<AudioProvider>()
                      .setPlaylist(songs, index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NowPlayingScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}