import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAlbumArt(context),
      title: Text(
        song.title,
        style: TextStyle(
          color: AppColors.text(context),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(color: AppColors.mutedText(context)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.mutedText(context)),
            onPressed: () => _showOptionsMenu(context),
          ),
      onTap: onTap,
    );
  }

  Widget _buildAlbumArt(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.tile(context),
      ),
      child: song.albumArt != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(File(song.albumArt!), fit: BoxFit.cover),
      )
          : const Icon(Icons.music_note, color: Colors.grey),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Add to playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharing requires a share plugin.'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Song info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSongInfo(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context) {
    final provider = context.read<PlaylistProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (sheetContext) {
        return Consumer<PlaylistProvider>(
          builder: (context, playlistProvider, child) {
            if (playlistProvider.playlists.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No playlists yet',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showCreatePlaylistDialog(context, provider);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create playlist'),
                    ),
                  ],
                ),
              );
            }

            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Add to playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...playlistProvider.playlists.map((playlist) {
                    final alreadyAdded = playlist.songIds.contains(song.id);
                    return ListTile(
                      leading: Icon(
                        alreadyAdded ? Icons.check : Icons.playlist_add,
                        color: alreadyAdded
                            ? const Color(0xFF1DB954)
                            : Colors.white,
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        alreadyAdded ? 'Already added' : 'Tap to add',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: alreadyAdded
                          ? null
                          : () async {
                              await playlistProvider.addSongToPlaylist(
                                playlist.id,
                                song.id,
                              );
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePlaylistDialog(
    BuildContext context,
    PlaylistProvider provider,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'New Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DB954)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await provider.createPlaylist(name);
              final playlist = provider.playlists.last;
              await provider.addSongToPlaylist(playlist.id, song.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSongInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Song info', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Title', song.title),
            _infoRow('Artist', song.artist),
            _infoRow('Album', song.album ?? 'Unknown Album'),
            _infoRow('Duration', _formatDuration(song.duration)),
            _infoRow('Path', song.filePath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null || duration == Duration.zero) return 'Unknown';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
