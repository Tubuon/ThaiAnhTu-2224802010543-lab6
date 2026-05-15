import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/widgets/progress_bar.dart';

void main() {
  test('SongModel serializes duration in milliseconds', () {
    final song = SongModel(
      id: '1',
      title: 'Test Song',
      artist: 'Test Artist',
      album: 'Test Album',
      filePath: '/sdcard/Music/test.mp3',
      duration: const Duration(seconds: 90),
    );

    final restored = SongModel.fromJson(song.toJson());

    expect(restored.id, '1');
    expect(restored.duration, const Duration(seconds: 90));
    expect(restored.album, 'Test Album');
  });

  test('PlaylistModel copyWith updates song order', () {
    final playlist = PlaylistModel(
      id: 'p1',
      name: 'Favorites',
      songIds: const ['a', 'b', 'c'],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final updated = playlist.copyWith(songIds: const ['b', 'a', 'c']);

    expect(updated.songIds, ['b', 'a', 'c']);
    expect(updated.name, 'Favorites');
  });

  testWidgets('ProgressBar shows current and total duration', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressBar(
            position: const Duration(minutes: 1, seconds: 5),
            duration: const Duration(minutes: 3, seconds: 30),
            onSeek: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('01:05'), findsOneWidget);
    expect(find.text('03:30'), findsOneWidget);
  });
}
