import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;
  final _uuid = const Uuid();

  List<PlaylistModel> _playlists = [];

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => _playlists;

  Future<void> _loadPlaylists() async {
    _playlists = await _storageService.getPlaylists();
    notifyListeners();
  }

  // Create a new playlist
  Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: _uuid.v4(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists.add(playlist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  // Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  // Rename a playlist
  Future<void> renamePlaylist(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(name: newName);
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  // Add song to playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      if (!playlist.songIds.contains(songId)) {
        final updatedIds = [...playlist.songIds, songId];
        _playlists[index] = playlist.copyWith(songIds: updatedIds);
        await _storageService.savePlaylists(_playlists);
        notifyListeners();
      }
    }
  }

  // Remove song from playlist
  Future<void> removeSongFromPlaylist(
      String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedIds =
      _playlists[index].songIds.where((id) => id != songId).toList();
      _playlists[index] = _playlists[index].copyWith(songIds: updatedIds);
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  // Get songs of a playlist filtered from all songs
  List<SongModel> getPlaylistSongs(
      PlaylistModel playlist, List<SongModel> allSongs) {
    return playlist.songIds
        .map((id) => allSongs.where((s) => s.id == id).firstOrNull)
        .whereType<SongModel>()
        .toList();
  }
}