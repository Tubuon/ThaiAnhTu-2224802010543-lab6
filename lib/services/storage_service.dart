import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const String _playlistsKey = 'playlists';
  static const String _lastPlayedKey = 'last_played';
  static const String _lastPositionKey = 'last_position';
  static const String _recentlyPlayedKey = 'recently_played';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';
  static const String _volumeKey = 'volume';
  static const String _speedKey = 'playback_speed';

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final data = playlists.map((p) => p.toJson()).toList();
    await prefs.setString(_playlistsKey, json.encode(data));
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_playlistsKey);
    if (str != null) {
      final List<dynamic> data = json.decode(str);
      return data.map((j) => PlaylistModel.fromJson(j)).toList();
    }
    return [];
  }

  Future<void> saveLastPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedKey, songId);
  }

  Future<String?> getLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedKey);
  }

  Future<void> saveLastPosition(Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPositionKey, position.inMilliseconds);
  }

  Future<Duration> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return Duration(milliseconds: prefs.getInt(_lastPositionKey) ?? 0);
  }

  Future<void> addRecentlyPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(_recentlyPlayedKey) ?? [];
    recent.remove(songId);
    recent.insert(0, songId);
    await prefs.setStringList(_recentlyPlayedKey, recent.take(20).toList());
  }

  Future<List<String>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentlyPlayedKey) ?? [];
  }

  Future<void> saveShuffleState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, enabled);
  }

  Future<bool> getShuffleState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveRepeatMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatKey, mode);
  }

  Future<int> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatKey) ?? 0;
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }

  Future<void> saveSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedKey, speed);
  }

  Future<double> getSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_speedKey) ?? 1.0;
  }
}
