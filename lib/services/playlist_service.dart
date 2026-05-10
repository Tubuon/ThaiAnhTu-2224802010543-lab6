import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart' as app_models;

class PlaylistService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<app_models.SongModel>> getAllSongs() async {
    try {
      final audioList = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      return audioList.map((audio) => app_models.SongModel(
        id: audio.id.toString(),
        title: audio.title,
        artist: audio.artist ?? 'Unknown Artist',
        album: audio.album,
        filePath: audio.data,
        duration: Duration(milliseconds: audio.duration ?? 0),
      )).toList();
    } catch (e) {
      throw Exception('Lỗi load nhạc: $e');
    }
  }

  Future<List<app_models.SongModel>> getSongsByArtist(String artist) async {
    final all = await getAllSongs();
    return all.where((s) => s.artist == artist).toList();
  }

  Future<List<app_models.SongModel>> getSongsByAlbum(String album) async {
    final all = await getAllSongs();
    return all.where((s) => s.album == album).toList();
  }

  Future<List<app_models.SongModel>> searchSongs(String query) async {
    final all = await getAllSongs();
    final q = query.toLowerCase();
    return all.where((s) =>
    s.title.toLowerCase().contains(q) ||
        s.artist.toLowerCase().contains(q) ||
        (s.album?.toLowerCase().contains(q) ?? false)
    ).toList();
  }
}