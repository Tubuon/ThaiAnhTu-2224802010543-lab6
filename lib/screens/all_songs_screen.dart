import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

enum SongSortMode { title, artist, album }

class AllSongsScreen extends StatefulWidget {
  final List<SongModel> songs;

  const AllSongsScreen({super.key, required this.songs});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  SongSortMode _sortMode = SongSortMode.title;
  String? _artistFilter;
  String? _albumFilter;

  @override
  Widget build(BuildContext context) {
    final songs = _visibleSongs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'All Songs',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Sort',
                icon: Icon(Icons.sort, color: AppColors.icon(context)),
                onPressed: _showSortMenu,
              ),
              IconButton(
                tooltip: 'Filter',
                icon: Icon(
                  Icons.filter_list,
                  color: _hasFilter ? const Color(0xFF1DB954) : AppColors.icon(context),
                ),
                onPressed: _showFilterMenu,
              ),
            ],
          ),
        ),
        if (_hasFilter)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                if (_artistFilter != null)
                  _FilterChip(
                    label: 'Artist: $_artistFilter',
                    onDeleted: () => setState(() => _artistFilter = null),
                  ),
                if (_albumFilter != null)
                  _FilterChip(
                    label: 'Album: $_albumFilter',
                    onDeleted: () => setState(() => _albumFilter = null),
                  ),
              ],
            ),
          ),
        Expanded(
          child: songs.isEmpty
              ? Center(
            child: Text(
              'No songs found',
              style: TextStyle(color: AppColors.mutedText(context)),
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

  bool get _hasFilter => _artistFilter != null || _albumFilter != null;

  List<SongModel> _visibleSongs() {
    final filtered = widget.songs.where((song) {
      final artistMatches = _artistFilter == null || song.artist == _artistFilter;
      final albumMatches = _albumFilter == null || song.album == _albumFilter;
      return artistMatches && albumMatches;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortMode) {
        case SongSortMode.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SongSortMode.artist:
          return a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
        case SongSortMode.album:
          return (a.album ?? '').toLowerCase().compareTo(
                (b.album ?? '').toLowerCase(),
              );
      }
    });

    return filtered;
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sortTile('Title', SongSortMode.title),
            _sortTile('Artist', SongSortMode.artist),
            _sortTile('Album', SongSortMode.album),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(String label, SongSortMode mode) {
    return ListTile(
      leading: Icon(
        _sortMode == mode ? Icons.check : Icons.sort,
        color: _sortMode == mode ? const Color(0xFF1DB954) : Colors.white,
      ),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        setState(() => _sortMode = mode);
        Navigator.pop(context);
      },
    );
  }

  void _showFilterMenu() {
    final artists = widget.songs.map((s) => s.artist).toSet().toList()..sort();
    final albums = widget.songs
        .map((s) => s.album)
        .whereType<String>()
        .where((album) => album.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (context) => DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              const TabBar(
                indicatorColor: Color(0xFF1DB954),
                tabs: [
                  Tab(text: 'Artists'),
                  Tab(text: 'Albums'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _filterList(artists, (value) => _artistFilter = value),
                    _filterList(albums, (value) => _albumFilter = value),
                  ],
                ),
              ),
              if (_hasFilter)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _artistFilter = null;
                      _albumFilter = null;
                    });
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  label: const Text(
                    'Clear filters',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterList(List<String> values, ValueChanged<String> updateFilter) {
    if (values.isEmpty) {
      return const Center(
        child: Text('No values found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final value = values[index];
        final selected = value == _artistFilter || value == _albumFilter;
        return ListTile(
          leading: Icon(
            selected ? Icons.check : Icons.music_note,
            color: selected ? const Color(0xFF1DB954) : Colors.white,
          ),
          title: Text(value, style: const TextStyle(color: Colors.white)),
          onTap: () {
            setState(() => updateFilter(value));
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: const Color(0xFF282828),
      deleteIconColor: Colors.grey,
      label: Text(label, style: const TextStyle(color: Colors.white)),
      onDeleted: onDeleted,
    );
  }
}
