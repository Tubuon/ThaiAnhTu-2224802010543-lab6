import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class PlaylistScreen extends StatelessWidget {
  final List<SongModel> allSongs;

  const PlaylistScreen({super.key, required this.allSongs});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Playlists',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF1DB954)),
                    onPressed: () =>
                        _showCreatePlaylistDialog(context, provider),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.playlists.isEmpty
                  ? const Center(
                  child: Text('No playlists yet',
                      style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                itemCount: provider.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = provider.playlists[index];
                  return _buildPlaylistCard(
                      context, playlist, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaylistCard(BuildContext context, PlaylistModel playlist,
      PlaylistProvider provider) {
    final songs =
    provider.getPlaylistSongs(playlist, allSongs);
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.queue_music, color: Color(0xFF1DB954)),
      ),
      title: Text(playlist.name,
          style: const TextStyle(color: Colors.white)),
      subtitle: Text('${songs.length} songs',
          style: const TextStyle(color: Colors.grey)),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        color: const Color(0xFF282828),
        onSelected: (value) {
          if (value == 'rename') {
            _showRenameDialog(context, playlist, provider);
          } else if (value == 'delete') {
            provider.deletePlaylist(playlist.id);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'rename',
            child: Text('Rename', style: TextStyle(color: Colors.white)),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      onTap: () => _openPlaylist(context, playlist, songs),
    );
  }

  void _openPlaylist(BuildContext context, PlaylistModel playlist,
      List<SongModel> songs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(
          playlist: playlist,
          songs: songs,
          allSongs: allSongs,
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(
      BuildContext context, PlaylistProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('New Playlist',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create',
                style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, PlaylistModel playlist,
      PlaylistProvider provider) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Rename Playlist',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.renamePlaylist(playlist.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }
}

// Playlist Detail Screen
class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistModel playlist;
  final List<SongModel> songs;
  final List<SongModel> allSongs;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.songs,
    required this.allSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(playlist.name,
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1DB954)),
            onPressed: () => _showAddSongsDialog(context),
          ),
        ],
      ),
      body: songs.isEmpty
          ? const Center(
          child: Text('No songs in this playlist',
              style: TextStyle(color: Colors.grey)))
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
                    builder: (_) => const NowPlayingScreen()),
              );
            },
            trailing: IconButton(
              icon:
              const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                context
                    .read<PlaylistProvider>()
                    .removeSongFromPlaylist(
                    playlist.id, songs[index].id);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddSongsDialog(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    final existingIds = playlist.songIds.toSet();
    final available =
    allSongs.where((s) => !existingIds.contains(s.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (_) => ListView.builder(
        itemCount: available.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(available[i].title,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(available[i].artist,
              style: const TextStyle(color: Colors.grey)),
          onTap: () {
            playlistProvider.addSongToPlaylist(
                playlist.id, available[i].id);
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }
}