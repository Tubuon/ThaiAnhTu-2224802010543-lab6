import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';
import 'all_songs_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();
  final StorageService _storageService = StorageService();

  List<SongModel> _songs = [];
  List<SongModel> _recentSongs = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _hasPermission = await _permissionService.requestStoragePermission();

    if (_hasPermission) {
      await _permissionService.requestAudioPermission();
      await _loadSongs();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      final recentIds = await _storageService.getRecentlyPlayed();
      final recentSongs = recentIds
          .map((id) => songs.where((song) => song.id == id).firstOrNull)
          .whereType<SongModel>()
          .toList();
      setState(() {
        _songs = songs;
        _recentSongs = recentSongs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading songs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _getScreen()),
            Consumer<AudioProvider>(
              builder: (context, provider, child) {
                if (provider.currentSong == null) {
                  return const SizedBox.shrink();
                }
                return const MiniPlayer();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface(context),
        selectedItemColor: const Color(0xFF1DB954),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return AllSongsScreen(songs: _songs);
      case 2:
        return PlaylistScreen(allSongs: _songs);
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      );
    }
    if (!_hasPermission) return _buildPermissionDenied();
    if (_songs.isEmpty) return _buildNoSongs();
    return _buildSongList();
  }

  Widget _buildSongList() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: ListView(
            children: [
              if (_recentSongs.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'Recently Played',
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _recentSongs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final song = _recentSongs[index];
                      return _RecentSongCard(
                        song: song,
                        onTap: () => _playSongs(_recentSongs, index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'All Music',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...List.generate(_songs.length, (index) {
                return SongTile(
                  song: _songs[index],
                  onTap: () => _playSongs(_songs, index),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  void _playSongs(List<SongModel> songs, int index) {
    context.read<AudioProvider>().setPlaylist(songs, index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NowPlayingScreen(),
      ),
    ).then((_) => _loadSongs());
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Music',
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: AppColors.icon(context)),
            onPressed: () => showSearch(
              context: context,
              delegate: SongSearchDelegate(_songs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Storage Permission Required',
            style: TextStyle(color: AppColors.text(context), fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            'Please grant storage permission to access music',
            style: TextStyle(color: AppColors.mutedText(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
            ),
            onPressed: () async => await openAppSettings(),
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No Music Found',
            style: TextStyle(color: AppColors.text(context), fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            'Add some music files to your device',
            style: TextStyle(color: AppColors.mutedText(context)),
          ),
        ],
      ),
    );
  }
}

// ── Search Delegate ──────────────────────────────────────────────
class _RecentSongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const _RecentSongCard({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.music_note, color: Colors.grey),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.mutedText(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongSearchDelegate extends SearchDelegate<SongModel?> {
  final List<SongModel> songs;

  SongSearchDelegate(this.songs);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: AppColors.background(context),
      appBarTheme: AppBarTheme(backgroundColor: AppColors.background(context)),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.mutedText(context)),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: AppColors.text(context)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear, color: AppColors.icon(context)),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back, color: AppColors.icon(context)),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = songs
        .where((s) =>
    s.title.toLowerCase().contains(query.toLowerCase()) ||
        s.artist.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Container(
      color: AppColors.background(context),
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return SongTile(
            song: results[index],
            onTap: () {
              context
                  .read<AudioProvider>()
                  .setPlaylist(results, index);
              close(context, results[index]);
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
    );
  }
}
